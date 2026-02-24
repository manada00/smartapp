import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET() {
  const data = await fetchAdmin('/api/v1/admin/menu');
  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load menu' }, { status: 500 });
  }

  return NextResponse.json(data);
}

export async function POST(request: Request) {
  const body = await request.json();
  const data = await fetchAdmin('/api/v1/admin/menu', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to create menu item' }, { status: 500 });
  }

  return NextResponse.json(data, { status: 201 });
}
