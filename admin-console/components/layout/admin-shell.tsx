'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { Activity, BarChart3, Globe, LayoutDashboard, ListOrdered, Settings, Tags, Ticket, Users, UtensilsCrossed } from 'lucide-react';
import type { ReactNode } from 'react';
import { useState } from 'react';
import { roleLabel, type AdminRole } from '@/lib/rbac';
import { Button } from '@/components/ui/primitives';

const navItems = [
  { href: '/dashboard', label: 'Overview', icon: LayoutDashboard },
  { href: '/orders', label: 'Orders', icon: ListOrdered },
  { href: '/menu', label: 'Menu', icon: UtensilsCrossed },
  { href: '/categories', label: 'Categories', icon: Tags },
  { href: '/users', label: 'Users', icon: Users },
  { href: '/reports', label: 'Reports', icon: BarChart3 },
  { href: '/support', label: 'Support', icon: Ticket },
  { href: '/website', label: 'Website', icon: Globe },
  { href: '/settings', label: 'Settings', icon: Settings },
  { href: '/monitoring', label: 'Monitoring', icon: Activity },
];

export function AdminShell({ role, children }: { role: AdminRole; children: ReactNode }) {
  const path = usePathname();
  const router = useRouter();
  const [collapsed, setCollapsed] = useState(false);

  const crumbs = path
    .split('/')
    .filter(Boolean)
    .map((c) => c[0].toUpperCase() + c.slice(1));

  async function logout() {
    await fetch('/api/auth/logout', { method: 'POST' });
    router.replace('/login');
  }

  function toggleTheme() {
    document.documentElement.classList.toggle('dark');
  }

  return (
    <div className={collapsed ? 'shell collapsed' : 'shell'}>
      <aside className="sidebar">
        <div>
          <h1>smartApp Admin</h1>
          <p>{roleLabel[role]}</p>
          <Button variant="ghost" onClick={() => setCollapsed((prev) => !prev)} style={{ marginTop: 10 }}>
            {collapsed ? 'Expand' : 'Collapse'}
          </Button>
        </div>
        <nav>
          {navItems.map(({ href, label, icon: Icon }) => (
            <Link key={href} href={href} className={path === href ? 'nav-item active' : 'nav-item'}>
              <Icon size={16} /> {label}
            </Link>
          ))}
        </nav>
      </aside>
      <main>
        <header className="topbar">
          <div className="crumbs">{crumbs.join(' / ') || 'Dashboard'}</div>
          <div className="topbar-actions">
            <Button variant="ghost" onClick={toggleTheme}>Dark mode</Button>
            <Button variant="ghost" onClick={logout}>Logout</Button>
          </div>
        </header>
        {children}
      </main>
    </div>
  );
}
