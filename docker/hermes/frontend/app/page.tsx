"use client";

import { useEffect, useState } from "react";
import {
  BarVisualizer,
  LiveKitRoom,
  RoomAudioRenderer,
  VoiceAssistantControlBar,
  useVoiceAssistant,
} from "@livekit/components-react";

type Creds = { token: string; url: string };

export default function Home() {
  const [creds, setCreds] = useState<Creds | null>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    fetch("/api/token")
      .then((r) => r.json())
      .then((d: Creds & { error?: string }) => {
        if (d.token && d.url) setCreds({ token: d.token, url: d.url });
        else setErr(d.error ?? "no token returned");
      })
      .catch((e) => setErr(String(e)));
  }, []);

  if (err) return <main className="status">error: {err}</main>;
  if (!creds) return <main className="status">connecting…</main>;

  return (
    <LiveKitRoom
      token={creds.token}
      serverUrl={creds.url}
      connect
      audio
      video={false}
      onDisconnected={() => setCreds(null)}
    >
      <Assistant />
      <RoomAudioRenderer />
    </LiveKitRoom>
  );
}

function Assistant() {
  const { state, audioTrack } = useVoiceAssistant();
  return (
    <main className="root">
      <header>
        <h1>Hermes</h1>
        <span className="state">{state}</span>
      </header>
      <div className="viz">
        <BarVisualizer state={state} trackRef={audioTrack} barCount={9} />
      </div>
      <div className="controls">
        <VoiceAssistantControlBar />
      </div>
    </main>
  );
}
