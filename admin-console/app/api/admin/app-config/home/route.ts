import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET() {
  const data = await fetchAdmin('/api/v1/admin/app-config/home');
  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load home app config' }, { status: 500 });
  }

  return NextResponse.json(data);
}

export async function PUT(request: Request) {
  const body = await request.json();
  const data = await fetchAdmin('/api/v1/admin/app-config/home', {
    method: 'PUT',
    body: JSON.stringify(body),
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to save home app config' }, { status: 500 });
  }

  return NextResponse.json(data);
}
