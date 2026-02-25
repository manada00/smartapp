import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function GET(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const { search } = new URL(request.url);
  const data = await fetchAdmin(`/api/v1/admin/users/${id}/orders${search}`);

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to load order history' }, { status: 500 });
  }

  return NextResponse.json(data);
}
