import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import type { ReactNode } from 'react';
import { AdminShell } from '@/components/layout/admin-shell';
import type { AdminRole } from '@/lib/rbac';

export default async function ProtectedLayout({ children }: { children: ReactNode }) {
  const cookieStore = await cookies();
  const role = cookieStore.get('smartapp_role')?.value as AdminRole | undefined;
  const token = cookieStore.get('smartapp_access_token')?.value;

  if (!token || !role) redirect('/login');

  return <AdminShell role={role}>{children}</AdminShell>;
}
