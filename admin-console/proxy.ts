import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const protectedRoutes = ['/dashboard', '/orders', '/menu', '/categories', '/users', '/reports', '/support', '/settings', '/monitoring'];
const roleRouteAccess: Record<string, string[]> = {
  '/menu': ['SUPER_ADMIN', 'OPERATIONS_ADMIN'],
  '/categories': ['SUPER_ADMIN', 'OPERATIONS_ADMIN'],
  '/settings': ['SUPER_ADMIN'],
  '/support': ['SUPER_ADMIN', 'SUPPORT_ADMIN'],
  '/users': ['SUPER_ADMIN', 'SUPPORT_ADMIN'],
};

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const isProtected = protectedRoutes.some((route) => pathname.startsWith(route));
  if (!isProtected) return NextResponse.next();

  const token = request.cookies.get('smartapp_access_token')?.value;
  const role = request.cookies.get('smartapp_role')?.value;

  if (!token || !role) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  const denied = Object.entries(roleRouteAccess).some(
    ([route, allowed]) => pathname.startsWith(route) && !allowed.includes(role),
  );

  if (denied) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|api).*)'],
};
