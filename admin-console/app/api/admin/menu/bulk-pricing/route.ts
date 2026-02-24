import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function POST(request: Request) {
  const body = await request.json();
  const data = await fetchAdmin('/api/v1/admin/menu/bulk-pricing', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to apply bulk pricing' }, { status: 500 });
  }

  return NextResponse.json(data);
}
