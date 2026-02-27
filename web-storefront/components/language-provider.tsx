'use client';

import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { type Lang, t as translate } from '@/lib/i18n';

type LanguageContextValue = {
  lang: Lang;
  setLang: (lang: Lang) => void;
  t: (key: string) => string;
};

const LanguageContext = createContext<LanguageContextValue | null>(null);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>('en');

  useEffect(() => {
    const saved = window.localStorage.getItem('smartapp_lang');
    if (saved === 'ar' || saved === 'en') setLangState(saved);
  }, []);

  useEffect(() => {
    window.localStorage.setItem('smartapp_lang', lang);
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
  }, [lang]);

  const value = useMemo(
    () => ({
      lang,
      setLang: (nextLang: Lang) => setLangState(nextLang),
      t: (key: string) => translate(lang, key),
    }),
    [lang],
  );

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) throw new Error('useLanguage must be used within LanguageProvider');
  return context;
}
