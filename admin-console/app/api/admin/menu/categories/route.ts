import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET() {
  const data = await fetchAdmin('/api/v1/admin/menu/categories?includeInactive=true');
  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load categories' }, { status: 500 });
  }

  return NextResponse.json(data);
}

export async function POST(request: Request) {
  const body = await request.json();
  const data = await fetchAdmin('/api/v1/admin/menu/categories', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to create category' }, { status: 500 });
  }

  return NextResponse.json(data, { status: 201 });
}
