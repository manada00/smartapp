import { NextResponse } from 'next/server';

export async function POST() {
  const isProd = process.env.NODE_ENV === 'production';
  const response = NextResponse.json({ ok: true });
  const cookieOptions = { expires: new Date(0), path: '/', httpOnly: true, secure: isProd, sameSite: 'strict' as const };

  for (const cookie of ['smartapp_access_token', 'smartapp_refresh_token', 'smartapp_role', 'smartapp_user_email']) {
    response.cookies.set(cookie, '', cookieOptions);
  }

  return response;
}
