import { NextResponse } from 'next/server';
import type { AdminRole } from '@/lib/rbac';
import { getBackendUrl } from '@/lib/backend';

type BackendLoginResponse = {
  success: boolean;
  data?: {
    accessToken: string;
    admin: { email: string; role: AdminRole };
  };
  message?: string;
};

export async function POST(req: Request) {
  try {
    const isProd = process.env.NODE_ENV === 'production';
    const origin = req.headers.get('origin');
    const host = req.headers.get('x-forwarded-host') || req.headers.get('host');
    const proto = req.headers.get('x-forwarded-proto') || (isProd ? 'https' : 'http');

    if (origin && host && origin !== `${proto}://${host}`) {
      return NextResponse.json({ message: 'Invalid request origin.' }, { status: 403 });
    }

    const { email, password } = await req.json();
    if (!email || !password) {
      return NextResponse.json({ message: 'Email and password are required.' }, { status: 400 });
    }

    const authRes = await fetch(`${getBackendUrl()}/api/v1/admin/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email: String(email).trim(), password }),
    });

    const backendPayload = (await authRes.json().catch(() => null)) as BackendLoginResponse | null;

    if (!authRes.ok) {
      return NextResponse.json(
        { message: backendPayload?.message || 'Login failed.' },
        { status: authRes.status },
      );
    }

    const authData = backendPayload as BackendLoginResponse | null;
    if (!authData?.success || !authData.data?.accessToken || !authData.data.admin?.role) {
      return NextResponse.json({ message: authData?.message || 'Login failed.' }, { status: 401 });
    }

    const role = authData.data.admin.role;
    const response = NextResponse.json({ ok: true, role });
    const cookieOptions = { httpOnly: true, secure: isProd, sameSite: 'strict' as const, path: '/', maxAge: 60 * 60 * 8 };
    response.cookies.set('smartapp_access_token', authData.data.accessToken, cookieOptions);
    response.cookies.set('smartapp_role', role, cookieOptions);
    response.cookies.set('smartapp_user_email', authData.data.admin.email || email, cookieOptions);

    return response;
  } catch {
    return NextResponse.json({ message: 'Login failed.' }, { status: 500 });
  }
}
