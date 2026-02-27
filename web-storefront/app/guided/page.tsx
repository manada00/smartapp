'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { apiRequest } from '@/lib/api';
import { filterFoodsByMood, guidedMoods } from '@/lib/guided-moods';
import { mockDrinksSweetsFoods } from '@/lib/mock-drinks-sweets';
import type { FoodItem } from '@/lib/types';

type ApiListResponse<T> = { data: T[] };

export default function GuidedPage() {
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
        <h1 style={{ margin: 0 }}>Help me choose</h1>
        <Link href="/meals" className="btn secondary">Browse Menu Instead</Link>
      </div>
      <p className="muted">Pick a mood and get curated meals, drinks, and sweets using SmartScore alignment.</p>

      <div className="guided-moods-grid">
        {guidedMoods.map((mood) => (
          <button
            key={mood.id}
            className={`guided-mood-card ${selectedMood === mood.id ? 'active' : ''}`}
            onClick={() => setSelectedMood(mood.id)}
          >
            <span>{mood.emoji}</span>
            <span>{mood.title}</span>
          </button>
        ))}
      </div>

      {loading ? <p className="muted">Loading recommendations...</p> : null}
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
