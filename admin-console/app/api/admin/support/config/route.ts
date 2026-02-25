import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET() {
  const data = await fetchAdmin('/api/v1/admin/app-config/support');
  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to fetch support config' }, { status: 500 });
  }
  return NextResponse.json(data);
}

export async function PUT(request: Request) {
  const body = await request.json();
  const data = await fetchAdmin('/api/v1/admin/app-config/support', {
    method: 'PUT',
    body: JSON.stringify(body),
  });
  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to update support config' }, { status: 500 });
  }
  return NextResponse.json(data);
}
