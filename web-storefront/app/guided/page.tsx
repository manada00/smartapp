'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { apiRequest } from '@/lib/api';
import { useLanguage } from '@/components/language-provider';
import { filterFoodsByMood, guidedMoods } from '@/lib/guided-moods';
import { mockDrinksSweetsFoods } from '@/lib/mock-drinks-sweets';
import type { FoodItem } from '@/lib/types';

type ApiListResponse<T> = { data: T[] };

export default function GuidedPage() {
  const { t, lang } = useLanguage();
  const [foods, setFoods] = useState<FoodItem[]>([]);
  const [selectedMood, setSelectedMood] = useState(guidedMoods[0].id);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const response = await apiRequest<ApiListResponse<FoodItem>>('/food?limit=100');
        setFoods([...(response.data || []), ...mockDrinksSweetsFoods]);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const visibleFoods = useMemo(() => filterFoodsByMood(foods, selectedMood).slice(0, 8), [foods, selectedMood]);

  return (
    <section className="section">
      <div className="toolbar">
        <h1 style={{ margin: 0 }}>{t('guidedTitle')}</h1>
        <Link href="/meals" className="btn secondary">{t('browseMenuInstead')}</Link>
      </div>
      <p className="muted">{t('guidedSubtitle')}</p>

      <div className="guided-moods-grid">
        {guidedMoods.map((mood) => (
          <button
            key={mood.id}
            className={`guided-mood-card ${selectedMood === mood.id ? 'active' : ''}`}
            onClick={() => setSelectedMood(mood.id)}
            style={{ backgroundImage: `linear-gradient(rgba(20,20,20,0.35), rgba(20,20,20,0.45)), url(${mood.image})` }}
          >
            <span>{mood.emoji}</span>
            <span>{lang === 'ar' ? mood.titleAr : mood.title}</span>
          </button>
        ))}
      </div>

      {loading ? <p className="muted">{t('loadingRecommendations')}</p> : null}
      <div className="grid cols-4">
        {visibleFoods.map((food) => (
          <Link key={food._id} href={`/meals/${food._id}`} className="card">
            {food.images?.[0] ? <img src={food.images[0]} alt={food.name} className="meal-image" /> : <div className="meal-image placeholder">No image</div>}
            <h3>{food.name}</h3>
            <p className="muted">{food.description}</p>
            <p><strong>{food.price} EGP</strong></p>
          </Link>
        ))}
      </div>
    </section>
  );
}
