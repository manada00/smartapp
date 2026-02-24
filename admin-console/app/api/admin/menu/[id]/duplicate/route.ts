import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function POST(_: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const data = await fetchAdmin(`/api/v1/admin/menu/${id}/duplicate`, {
    method: 'POST',
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to duplicate menu item' }, { status: 500 });
  }

  return NextResponse.json(data, { status: 201 });
}
