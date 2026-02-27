const DEFAULT_API_URL = 'https://smartapp-kohl.vercel.app/api/v1';
const envApiUrl = process.env.NEXT_PUBLIC_API_URL?.trim();

const isLocalApi = Boolean(
  envApiUrl &&
  (envApiUrl.includes('localhost') || envApiUrl.includes('127.0.0.1') || envApiUrl.includes('0.0.0.0')),
);

export const API_URL = (envApiUrl && !isLocalApi ? envApiUrl : DEFAULT_API_URL).replace(/\/$/, '');
