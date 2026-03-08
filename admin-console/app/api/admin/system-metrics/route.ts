import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET(request: Request) {
  const { search } = new URL(request.url);
  const data = await fetchAdmin(`/api/v1/admin/system-metrics${search}`);

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load metrics' }, { status: 500 });
  }

  return NextResponse.json(data);
}
