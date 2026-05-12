"""Hermes voice agent — joins a LiveKit room, runs Gemini Live, exposes workspace tools."""

from __future__ import annotations

import asyncio
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from livekit import api
from loguru import logger

from pipecat.audio.vad.silero import SileroVADAnalyzer
from pipecat.pipeline.pipeline import Pipeline
from pipecat.pipeline.runner import PipelineRunner
from pipecat.pipeline.task import PipelineParams, PipelineTask
from pipecat.services.google.gemini_live.llm import (
    GeminiLiveLLMService,
    InputParams,
)
from pipecat.transports.livekit.transport import LiveKitParams, LiveKitTransport

from tools import build_system_prompt, build_tools


load_dotenv()

logger.remove()
logger.add(sys.stderr, level=os.environ.get("LOG_LEVEL", "INFO"))


WORKSPACE = Path(os.environ.get("HERMES_WORKSPACE", "/workspace"))
LIVEKIT_URL = os.environ["LIVEKIT_URL"]
LIVEKIT_API_KEY = os.environ["LIVEKIT_API_KEY"]
LIVEKIT_API_SECRET = os.environ["LIVEKIT_API_SECRET"]
LIVEKIT_ROOM = os.environ.get("LIVEKIT_ROOM", "hermes-main")

GEMINI_API_KEY = os.environ["GEMINI_API_KEY"]
GEMINI_VOICE = os.environ.get("GEMINI_VOICE", "Puck")
GEMINI_MODEL = os.environ.get(
    "GEMINI_MODEL",
    "models/gemini-2.5-flash-native-audio-preview-12-2025",
)
TEMPERATURE = float(os.environ.get("GEMINI_TEMPERATURE", "0.7"))


def make_agent_token() -> str:
    """Mint a LiveKit JWT for the agent process to join its room."""
    return (
        api.AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET)
        .with_identity("hermes")
        .with_name("Hermes")
        .with_grants(
            api.VideoGrants(
                room_join=True,
                room=LIVEKIT_ROOM,
                can_publish=True,
                can_subscribe=True,
                can_publish_data=True,
            )
        )
        .to_jwt()
    )


async def main() -> None:
    logger.info("hermes booting | workspace={} | room={}", WORKSPACE, LIVEKIT_ROOM)

    if not WORKSPACE.exists():
        logger.error("workspace {} does not exist", WORKSPACE)
        sys.exit(1)

    transport = LiveKitTransport(
        url=LIVEKIT_URL,
        token=make_agent_token(),
        room_name=LIVEKIT_ROOM,
        params=LiveKitParams(
            audio_in_enabled=True,
            audio_out_enabled=True,
            vad_enabled=True,
            vad_analyzer=SileroVADAnalyzer(),
        ),
    )

    tools = build_tools(WORKSPACE)
    system_prompt = build_system_prompt(WORKSPACE)
    logger.info("system prompt: {} chars", len(system_prompt))

    llm = GeminiLiveLLMService(
        api_key=GEMINI_API_KEY,
        voice_id=GEMINI_VOICE,
        model=GEMINI_MODEL,
        system_instruction=system_prompt,
        tools=tools.schemas,
        params=InputParams(temperature=TEMPERATURE),
    )

    for name, handler in tools.handlers.items():
        llm.register_function(name, handler)

    pipeline = Pipeline(
        [
            transport.input(),
            llm,
            transport.output(),
        ]
    )

    task = PipelineTask(
        pipeline,
        params=PipelineParams(
            allow_interruptions=True,
            enable_metrics=True,
        ),
    )

    @transport.event_handler("on_first_participant_joined")
    async def _on_join(_t, participant):  # noqa: ANN001
        logger.info("user joined: {}", getattr(participant, "identity", "?"))

    @transport.event_handler("on_participant_left")
    async def _on_leave(_t, participant, _reason):  # noqa: ANN001
        logger.info("user left: {}", getattr(participant, "identity", "?"))

    runner = PipelineRunner()
    await runner.run(task)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("shutting down")
