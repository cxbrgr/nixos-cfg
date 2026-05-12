import { AccessToken } from "livekit-server-sdk";
import { NextResponse } from "next/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET() {
  const apiKey = process.env.LIVEKIT_API_KEY;
  const apiSecret = process.env.LIVEKIT_API_SECRET;
  const url = process.env.LIVEKIT_URL;
  const room = process.env.LIVEKIT_ROOM ?? "hermes-main";

  if (!apiKey || !apiSecret || !url) {
    return NextResponse.json(
      { error: "missing LIVEKIT_URL / LIVEKIT_API_KEY / LIVEKIT_API_SECRET" },
      { status: 500 },
    );
  }

  const at = new AccessToken(apiKey, apiSecret, {
    identity: `chris-${Math.random().toString(36).slice(2, 10)}`,
    name: "Chris",
    ttl: 60 * 60,
  });
  at.addGrant({
    roomJoin: true,
    room,
    canPublish: true,
    canSubscribe: true,
    canPublishData: true,
  });

  const token = await at.toJwt();
  return NextResponse.json({ token, url });
}
