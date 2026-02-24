import { NextResponse } from 'next/server';

export async function POST() {
  const response = NextResponse.json({ ok: true });
  for (const cookie of ['smartapp_access_token', 'smartapp_refresh_token', 'smartapp_role', 'smartapp_user_email']) {
    response.cookies.set(cookie, '', { expires: new Date(0), path: '/' });
  }

  return response;
}
