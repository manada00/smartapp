'use client';

import Link from 'next/link';
import { useLanguage } from '@/components/language-provider';

export default function HomePage() {
  const { t } = useLanguage();

  return (
    <>
      <section className="hero entry-hero">
        <div className="hero-visual-strip" aria-hidden>
          <img src="https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?auto=format&fit=crop&w=900&q=80" alt="" />
          <img src="https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=900&q=80" alt="" />
          <img src="https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=900&q=80" alt="" />
        </div>
        <h1>{t('homeTitle')}</h1>
        <p>{t('homeSubtitle')}</p>
        <div className="entry-grid">
          <Link href="/meals" className="entry-card">
            <h3>{t('knowWhatIWant')}</h3>
            <p className="muted">{t('knowWhatIWantDesc')}</p>
          </Link>
          <Link href="/guided" className="entry-card">
            <h3>{t('helpMeChoose')}</h3>
            <p className="muted">{t('helpMeChooseDesc')}</p>
          </Link>
        </div>
        <div className="home-visual-sections">
          <div className="visual-category-card" style={{ backgroundImage: 'linear-gradient(rgba(20,20,20,.28), rgba(20,20,20,.52)), url(https://images.unsplash.com/photo-1467453678174-768ec283a940?auto=format&fit=crop&w=1200&q=80)' }}>
            <h4>{t('categoryInspirations')}</h4>
            <p>{t('categoryInspirationsDesc')}</p>
          </div>
          <div className="visual-category-card" style={{ backgroundImage: 'linear-gradient(rgba(20,20,20,.28), rgba(20,20,20,.52)), url(https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?auto=format&fit=crop&w=1200&q=80)' }}>
            <h4>{t('drinksSweets')}</h4>
            <p>{t('drinksSweetsDesc')}</p>
          </div>
        </div>
      </section>
    </>
  );
}
