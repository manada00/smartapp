import { hasPermission, type AdminRole, type Permission } from '@/lib/rbac';
import type { ReactNode } from 'react';

export function PermissionGate({
  role,
  permission,
  fallback = null,
  children,
}: {
  role: AdminRole;
  permission: Permission;
  fallback?: ReactNode;
  children: ReactNode;
}) {
  return hasPermission(role, permission) ? children : fallback;
}
