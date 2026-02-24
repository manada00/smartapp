import { cookies } from 'next/headers';

export function getBackendUrl() {
  return process.env.BACKEND_API_URL || 'http://localhost:3000';
}

export async function fetchAdmin(path: string, init?: RequestInit) {
  const token = (await cookies()).get('smartapp_access_token')?.value;
  const headers = new Headers(init?.headers);
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }
  headers.set('Content-Type', 'application/json');

  const response = await fetch(`${getBackendUrl()}${path}`, {
    ...init,
    headers,
    cache: 'no-store',
  });

  if (!response.ok) {
    return null;
  }

  return response.json();
}
