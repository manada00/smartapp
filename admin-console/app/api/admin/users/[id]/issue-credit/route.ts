import { NextResponse } from 'next/server';
import { fetchAdmin } from '@/lib/backend';

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const body = await request.json();
  const data = await fetchAdmin(`/api/v1/admin/users/${id}/issue-credit`, {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!data) {
    return NextResponse.json({ success: false, message: 'Failed to issue credit' }, { status: 500 });
  }

  return NextResponse.json(data);
}
