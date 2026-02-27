import './globals.css';
import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import { LanguageProvider } from '@/components/language-provider';
import SiteHeader from '@/components/site-header';

export const metadata: Metadata = {
  title: 'SmartApp Web',
  description: 'SmartApp premium food ordering platform',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <LanguageProvider>
          <SiteHeader />
          <main className="container">{children}</main>
        </LanguageProvider>
      </body>
    </html>
  );
}
