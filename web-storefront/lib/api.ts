import { API_URL, DEFAULT_API_URL } from '@/lib/config';
import { storage } from '@/lib/storage';

type RequestOptions = {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: unknown;
  token?: string | null;
};

export async function apiRequest<T>(path: string, options?: RequestOptions): Promise<T> {
  const token = options?.token ?? storage.getAccessToken();
  const baseUrls = API_URL === DEFAULT_API_URL ? [API_URL] : [API_URL, DEFAULT_API_URL];
  let lastError: Error | null = null;

  for (const baseUrl of baseUrls) {
    try {
      const response = await fetch(`${baseUrl}${path}`, {
        method: options?.method || 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: options?.body ? JSON.stringify(options.body) : undefined,
      });

      const responseType = response.headers.get('content-type') || '';
      if (!responseType.includes('application/json')) {
        const err = new Error('Invalid API response format.') as Error & { retryable?: boolean };
        err.retryable = true;
        throw err;
      }

      const data = await response.json();
      if (!response.ok || data?.success === false) {
        const err = new Error(data?.message || 'Request failed') as Error & { retryable?: boolean };
        err.retryable = !data?.message;
        throw err;
      }

      return data as T;
    } catch (e) {
      const err = e instanceof Error ? e : new Error('Request failed');
      const retryable = (e as { retryable?: boolean } | null)?.retryable ?? true;
      lastError = err;
      if (!retryable || baseUrl === baseUrls[baseUrls.length - 1]) {
        throw err;
      }
    }
  }

  throw lastError || new Error('Request failed');
}
