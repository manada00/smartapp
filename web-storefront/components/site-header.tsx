'use client';

import Link from 'next/link';
import { useLanguage } from '@/components/language-provider';

export default function SiteHeader() {
  const { lang, setLang, t } = useLanguage();

  return (
    <header className="top-nav">
      <div className="container nav-inner">
        <Link href="/" className="brand">SmartApp</Link>
        <nav className="nav-links">
          <Link href="/meals">{t('navMeals')}</Link>
          <Link href="/guided">{t('navGuided')}</Link>
          <Link href="/subscriptions">{t('navSubscriptions')}</Link>
          <Link href="/orders">{t('navOrders')}</Link>
          <Link href="/cart">{t('navCart')}</Link>
          <Link href="/login">{t('navLogin')}</Link>
        </nav>
        <div className="lang-switch" role="group" aria-label={t('language')}>
          <button className={`lang-btn ${lang === 'en' ? 'active' : ''}`} onClick={() => setLang('en')}>EN</button>
          <button className={`lang-btn ${lang === 'ar' ? 'active' : ''}`} onClick={() => setLang('ar')}>AR</button>
        </div>
      </div>
    </header>
  );
}
