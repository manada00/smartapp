import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function DELETE(_: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const data = await fetchAdmin(`/api/v1/admin/orders/${id}`, {
    method: 'DELETE',
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to delete order' }, { status: 500 });
  }

  return NextResponse.json(data);
}
