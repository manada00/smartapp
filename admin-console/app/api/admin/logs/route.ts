import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET() {
  const data = await fetchAdmin('/api/v1/admin/logs');

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load logs' }, { status: 500 });
  }

  return NextResponse.json(data);
}
