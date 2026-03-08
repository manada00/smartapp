import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET() {
  const data = await fetchAdmin('/api/v1/admin/system-health');

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load system health' }, { status: 500 });
  }

  return NextResponse.json(data);
}
