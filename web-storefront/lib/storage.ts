const ACCESS_TOKEN_KEY = 'smartapp_web_access_token';
const REFRESH_TOKEN_KEY = 'smartapp_web_refresh_token';
const CART_KEY = 'smartapp_web_cart';

export const storage = {
  getAccessToken() {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem(ACCESS_TOKEN_KEY);
  },
  setTokens(accessToken: string, refreshToken: string) {
    if (typeof window === 'undefined') return;
    localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
    localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
  },
  clearTokens() {
    if (typeof window === 'undefined') return;
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
  },
  getRefreshToken() {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem(REFRESH_TOKEN_KEY);
  },
  getCart<T>() {
    if (typeof window === 'undefined') return [] as T[];
    const raw = localStorage.getItem(CART_KEY);
    return raw ? (JSON.parse(raw) as T[]) : [];
  },
  setCart<T>(items: T[]) {
    if (typeof window === 'undefined') return;
    localStorage.setItem(CART_KEY, JSON.stringify(items));
  },
};
