"""Hermes tools: workspace-file operations exposed to Gemini as function calls."""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Awaitable, Callable

from loguru import logger

from pipecat.adapters.schemas.function_schema import FunctionSchema
from pipecat.adapters.schemas.tools_schema import ToolsSchema
from pipecat.services.llm_service import FunctionCallParams


Handler = Callable[[FunctionCallParams], Awaitable[None]]


@dataclass
class HermesTools:
    schemas: ToolsSchema
    handlers: dict[str, Handler]


def _safe_path(workspace: Path, rel: str) -> Path | None:
    """Resolve a workspace-relative path, refusing escapes."""
    target = (workspace / rel).resolve()
    try:
        target.relative_to(workspace.resolve())
    except ValueError:
        return None
    return target


def _today_file(workspace: Path) -> Path:
    return workspace / "memory" / f"{datetime.now():%Y-%m-%d}.md"


def _yesterday_file(workspace: Path) -> Path:
    return workspace / "memory" / f"{(datetime.now() - timedelta(days=1)):%Y-%m-%d}.md"


def build_system_prompt(workspace: Path) -> str:
    """Concatenate the foundational persona + memory files into a system prompt."""
    parts: list[str] = []
    for name in ("SOUL.md", "IDENTITY.md", "USER.md", "MEMORY.md", "AGENTS.md"):
        f = workspace / name
        if f.exists():
            parts.append(f"=== {name} ===\n\n{f.read_text()}")

    skills_dir = workspace / "skills"
    skill_lines: list[str] = []
    if skills_dir.exists():
        for d in sorted(skills_dir.iterdir()):
            if not d.is_dir():
                continue
            skill_md = d / "SKILL.md"
            blurb = ""
            if skill_md.exists():
                head = skill_md.read_text().splitlines()
                for line in head[1:6]:
                    line = line.strip()
                    if line and not line.startswith("#"):
                        blurb = line
                        break
            skill_lines.append(f"- {d.name}: {blurb}")
    skills_block = "\n".join(skill_lines) if skill_lines else "(no skills yet)"

    now = datetime.now()
    today_str = now.strftime("%A %Y-%m-%d %H:%M %Z").strip()

    return (
        "\n\n".join(parts)
        + f"\n\n=== Skills available ===\n\n{skills_block}\n\n"
        + "Use `read_skill(name)` when a skill is relevant.\n\n"
        + f"=== Right now ===\n\nIt is {today_str} in Vienna.\n\n"
        + "=== Voice rules ===\n\n"
        + "- You are speaking out loud. No markdown, no bullets, no headers in spoken output.\n"
        + "- Default to short replies. One or two sentences.\n"
        + "- One question at a time.\n"
        + "- Silence is okay. Don't fill it.\n"
        + "- If interrupted, pick up the new thread.\n"
    )


def build_tools(workspace: Path) -> HermesTools:
    workspace = workspace.resolve()
    (workspace / "memory").mkdir(parents=True, exist_ok=True)
    (workspace / "journal").mkdir(parents=True, exist_ok=True)

    # --- pure functions ---

    def _list_skills() -> dict:
        d = workspace / "skills"
        if not d.exists():
            return {"skills": []}
        return {"skills": [c.name for c in sorted(d.iterdir()) if c.is_dir()]}

    def _read_skill(name: str) -> dict:
        d = workspace / "skills" / name
        if not d.exists() or not d.is_dir():
            return {"error": f"skill {name!r} not found"}
        files: dict[str, str] = {}
        for f in sorted(d.rglob("*.md")):
            files[str(f.relative_to(d))] = f.read_text()
        return {"name": name, "files": files}

    def _read_file(path: str) -> dict:
        target = _safe_path(workspace, path)
        if target is None:
            return {"error": "path escapes workspace"}
        if not target.exists():
            return {"error": f"{path!r} not found"}
        if target.is_dir():
            return {"error": f"{path!r} is a directory"}
        return {"path": path, "content": target.read_text()}

    def _append_today(content: str) -> dict:
        f = _today_file(workspace)
        f.parent.mkdir(parents=True, exist_ok=True)
        ts = datetime.now().strftime("%H:%M")
        if not f.exists():
            f.write_text(f"# {f.stem}\n\n")
        with f.open("a") as h:
            h.write(f"\n## {ts}\n\n{content.rstrip()}\n")
        return {"ok": True, "file": str(f.relative_to(workspace))}

    def _read_today() -> dict:
        f = _today_file(workspace)
        if not f.exists():
            return {"date": f.stem, "content": "", "empty": True}
        return {"date": f.stem, "content": f.read_text()}

    def _read_yesterday() -> dict:
        f = _yesterday_file(workspace)
        if not f.exists():
            return {"date": f.stem, "content": "", "empty": True}
        return {"date": f.stem, "content": f.read_text()}

    def _update_memory_index(entry: str) -> dict:
        f = workspace / "MEMORY.md"
        if not f.exists():
            f.write_text("# MEMORY.md\n\n")
        date = datetime.now().strftime("%Y-%m-%d")
        with f.open("a") as h:
            h.write(f"\n- [{date}] {entry.strip()}\n")
        return {"ok": True}

    def _recall(query: str, limit: int = 10) -> dict:
        q = query.lower()
        hits: list[dict] = []
        for f in workspace.rglob("*.md"):
            try:
                text = f.read_text()
            except (OSError, UnicodeDecodeError):
                continue
            lower = text.lower()
            idx = lower.find(q)
            if idx < 0:
                continue
            start = max(0, idx - 80)
            end = min(len(text), idx + 240)
            hits.append(
                {
                    "file": str(f.relative_to(workspace)),
                    "snippet": text[start:end].strip(),
                }
            )
            if len(hits) >= limit:
                break
        return {"query": query, "hits": hits}

    # --- function-call schemas (Gemini-compatible via FunctionSchema) ---

    schemas = ToolsSchema(
        standard_tools=[
            FunctionSchema(
                name="list_skills",
                description="List the names of available skills (directories under skills/).",
                properties={},
                required=[],
            ),
            FunctionSchema(
                name="read_skill",
                description="Read all markdown files inside a named skill directory.",
                properties={"name": {"type": "string", "description": "Skill name."}},
                required=["name"],
            ),
            FunctionSchema(
                name="read_file",
                description="Read a workspace file by path relative to the workspace root.",
                properties={"path": {"type": "string", "description": "Relative path."}},
                required=["path"],
            ),
            FunctionSchema(
                name="append_today",
                description=(
                    "Append a timestamped entry to today's daily memory file "
                    "(memory/YYYY-MM-DD.md). Use for in-conversation captures, "
                    "decisions, observations."
                ),
                properties={
                    "content": {
                        "type": "string",
                        "description": "Markdown content to append. A timestamp header is added automatically.",
                    }
                },
                required=["content"],
            ),
            FunctionSchema(
                name="read_today",
                description="Read today's daily memory file. Returns empty if nothing logged yet.",
                properties={},
                required=[],
            ),
            FunctionSchema(
                name="read_yesterday",
                description="Read yesterday's daily memory file. Returns empty if nothing.",
                properties={},
                required=[],
            ),
            FunctionSchema(
                name="update_memory_index",
                description=(
                    "Append a curated long-term memory entry to MEMORY.md. "
                    "Use sparingly — only for things worth remembering forever."
                ),
                properties={
                    "entry": {
                        "type": "string",
                        "description": "A single-line distilled memory.",
                    }
                },
                required=["entry"],
            ),
            FunctionSchema(
                name="recall",
                description="Search all workspace markdown files for a query string.",
                properties={"query": {"type": "string"}},
                required=["query"],
            ),
        ]
    )

    # --- handler wrappers (async, call result_callback) ---

    def _wrap(fn: Callable[..., dict], *, arg_names: tuple[str, ...] = ()) -> Handler:
        async def handler(params: FunctionCallParams) -> None:
            args = params.arguments or {}
            try:
                kwargs = {name: args[name] for name in arg_names if name in args}
                result = fn(**kwargs)
            except Exception as e:  # noqa: BLE001
                logger.exception("tool {} failed", fn.__name__)
                result = {"error": f"{type(e).__name__}: {e}"}
            logger.debug("tool {} → {}", fn.__name__, json.dumps(result)[:200])
            await params.result_callback(result)

        return handler

    handlers: dict[str, Handler] = {
        "list_skills": _wrap(_list_skills),
        "read_skill": _wrap(_read_skill, arg_names=("name",)),
        "read_file": _wrap(_read_file, arg_names=("path",)),
        "append_today": _wrap(_append_today, arg_names=("content",)),
        "read_today": _wrap(_read_today),
        "read_yesterday": _wrap(_read_yesterday),
        "update_memory_index": _wrap(_update_memory_index, arg_names=("entry",)),
        "recall": _wrap(_recall, arg_names=("query",)),
    }

    return HermesTools(schemas=schemas, handlers=handlers)
