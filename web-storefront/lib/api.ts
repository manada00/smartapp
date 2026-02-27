import { API_URL, DEFAULT_API_URL } from '@/lib/config';
import { storage } from '@/lib/storage';

type RequestOptions = {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: unknown;
  token?: string | null;
};

export async function apiRequest<T>(path: string, options?: RequestOptions): Promise<T> {
  const token = options?.token ?? storage.getAccessToken();
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  const baseUrls = API_URL === DEFAULT_API_URL ? [API_URL] : [API_URL, DEFAULT_API_URL];
  const endpoints = [`/api/proxy${normalizedPath}`, ...baseUrls.map((baseUrl) => `${baseUrl}${normalizedPath}`)];
  let lastError: Error | null = null;

  for (let index = 0; index < endpoints.length; index += 1) {
    const endpoint = endpoints[index];
    const isLastAttempt = index === endpoints.length - 1;
    try {
      const response = await fetch(endpoint, {
        method: options?.method || 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: options?.body ? JSON.stringify(options.body) : undefined,
      });

      const responseType = response.headers.get('content-type') || '';
      if (!responseType.includes('application/json')) {
        throw new Error('Invalid API response format.');
      }

      const data = await response.json();
      if (!response.ok || data?.success === false) {
        throw new Error(data?.message || 'Request failed');
      }

      return data as T;
    } catch (e) {
      lastError = e instanceof Error ? e : new Error('Request failed');
      if (isLastAttempt) {
        throw lastError;
      }
    }
  }

  throw lastError || new Error('Request failed');
}
