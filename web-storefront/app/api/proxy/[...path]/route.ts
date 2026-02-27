import { NextRequest, NextResponse } from 'next/server';
import { DEFAULT_API_URL } from '@/lib/config';

async function forward(request: NextRequest, path: string[]) {
  const targetUrl = new URL(`${DEFAULT_API_URL}/${path.join('/')}`);
  request.nextUrl.searchParams.forEach((value, key) => {
    targetUrl.searchParams.append(key, value);
  });

  const auth = request.headers.get('authorization');
  const contentType = request.headers.get('content-type');
  const body = request.method === 'GET' || request.method === 'DELETE' ? undefined : await request.text();

  const response = await fetch(targetUrl.toString(), {
    method: request.method,
    cache: 'no-store',
    headers: {
      ...(auth ? { Authorization: auth } : {}),
      ...(contentType ? { 'Content-Type': contentType } : {}),
    },
    body,
  });

  return new NextResponse(response.body, {
    status: response.status,
    headers: {
      'Content-Type': response.headers.get('content-type') || 'application/json',
      'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
      Pragma: 'no-cache',
      Expires: '0',
    },
  });
}

export async function GET(request: NextRequest, context: { params: { path: string[] } }) {
  return forward(request, context.params.path || []);
}

export async function POST(request: NextRequest, context: { params: { path: string[] } }) {
  return forward(request, context.params.path || []);
}

export async function PUT(request: NextRequest, context: { params: { path: string[] } }) {
  return forward(request, context.params.path || []);
}

export async function PATCH(request: NextRequest, context: { params: { path: string[] } }) {
  return forward(request, context.params.path || []);
}

export async function DELETE(request: NextRequest, context: { params: { path: string[] } }) {
  return forward(request, context.params.path || []);
}
