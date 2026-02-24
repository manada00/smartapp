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
    const { email, password } = await req.json();
    if (!email || !password) {
      return NextResponse.json({ message: 'Email and password are required.' }, { status: 400 });
    }

    const authRes = await fetch(`${getBackendUrl()}/api/v1/admin/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password }),
    });

    if (!authRes.ok) {
      return NextResponse.json({ message: 'Invalid credentials.' }, { status: 401 });
    }

    const authData = (await authRes.json()) as BackendLoginResponse;
    if (!authData.success || !authData.data?.accessToken || !authData.data.admin?.role) {
      return NextResponse.json({ message: authData.message || 'Login failed.' }, { status: 401 });
    }

    const role = authData.data.admin.role;
    const response = NextResponse.json({ ok: true, role });
    response.cookies.set('smartapp_access_token', authData.data.accessToken, { httpOnly: true, secure: isProd, sameSite: 'lax', path: '/' });
    response.cookies.set('smartapp_role', role, { httpOnly: true, secure: isProd, sameSite: 'lax', path: '/' });
    response.cookies.set('smartapp_user_email', authData.data.admin.email || email, { httpOnly: true, secure: isProd, sameSite: 'lax', path: '/' });

    return response;
  } catch {
    return NextResponse.json({ message: 'Login failed.' }, { status: 500 });
  }
}
