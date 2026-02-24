import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function POST(request: Request) {
  const body = await request.json();
  const data = await fetchAdmin('/api/v1/admin/menu/reorder', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to reorder menu items' }, { status: 500 });
  }

  return NextResponse.json(data);
}
