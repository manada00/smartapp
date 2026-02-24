export type AdminRole = 'SUPER_ADMIN' | 'OPERATIONS_ADMIN' | 'SUPPORT_ADMIN';

export type Permission =
  | 'orders.read'
  | 'orders.refund'
  | 'orders.export'
  | 'orders.delete'
  | 'orders.overridePaymentStatus'
  | 'orders.resendConfirmationEmail'
  | 'menu.manage'
  | 'stock.manage'
  | 'pricing.manage'
  | 'users.manage'
  | 'support.manage'
  | 'reports.read'
  | 'settings.manage'
  | 'monitoring.read';

const permissionsByRole: Record<AdminRole, Permission[]> = {
  SUPER_ADMIN: [
    'orders.read',
    'orders.refund',
    'orders.export',
    'orders.delete',
    'orders.overridePaymentStatus',
    'orders.resendConfirmationEmail',
    'menu.manage',
    'stock.manage',
    'pricing.manage',
    'users.manage',
    'support.manage',
    'reports.read',
    'settings.manage',
    'monitoring.read',
  ],
  OPERATIONS_ADMIN: [
    'orders.read',
    'orders.export',
    'menu.manage',
    'stock.manage',
    'reports.read',
    'monitoring.read',
  ],
  SUPPORT_ADMIN: [
    'orders.read',
    'orders.refund',
    'orders.resendConfirmationEmail',
    'support.manage',
    'users.manage',
    'reports.read',
  ],
};

export function hasPermission(role: AdminRole, permission: Permission): boolean {
  return permissionsByRole[role]?.includes(permission) ?? false;
}

export const roleLabel: Record<AdminRole, string> = {
  SUPER_ADMIN: 'Super Admin',
  OPERATIONS_ADMIN: 'Operations Admin',
  SUPPORT_ADMIN: 'Customer Support Admin',
};
