import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function DELETE(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const { search } = new URL(request.url);
  const data = await fetchAdmin(`/api/v1/admin/users/${id}${search}`, {
    method: 'DELETE',
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to delete user' }, { status: 500 });
  }

  return NextResponse.json(data);
}
