import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET() {
  const data = await fetchAdmin('/api/v1/admin/system-alerts');

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load alerts' }, { status: 500 });
  }

  return NextResponse.json(data);
}
