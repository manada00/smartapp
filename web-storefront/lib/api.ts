import { API_URL } from '@/lib/config';
import { storage } from '@/lib/storage';

type RequestOptions = {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: unknown;
  token?: string | null;
};

export async function apiRequest<T>(path: string, options?: RequestOptions): Promise<T> {
  const token = options?.token ?? storage.getAccessToken();
  const response = await fetch(`${API_URL}${path}`, {
    method: options?.method || 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: options?.body ? JSON.stringify(options.body) : undefined,
  });

  const data = await response.json();
  if (!response.ok || data?.success === false) {
    throw new Error(data?.message || 'Request failed');
  }

  return data as T;
}
