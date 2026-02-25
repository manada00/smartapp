import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET(request: Request) {
  const url = new URL(request.url);
  const query = url.searchParams.toString();
  const data = await fetchAdmin(`/api/v1/admin/support/tickets${query ? `?${query}` : ''}`);

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to fetch support tickets' }, { status: 500 });
  }

  return NextResponse.json(data);
}
