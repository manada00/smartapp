'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { apiRequest } from '@/lib/api';
import {
  drinksSweetsCategoryId,
  mockDrinksSweetsCategories,
  mockDrinksSweetsFoods,
} from '@/lib/mock-drinks-sweets';
import type { Category, FoodItem } from '@/lib/types';

type ApiListResponse<T> = { data: T[] };

export default function MealsPage() {
  const [foods, setFoods] = useState<FoodItem[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [category, setCategory] = useState('');
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    setCategory(params.get('category') || '');
  }, []);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const [foodsRes, categoriesRes] = await Promise.all([
          apiRequest<ApiListResponse<FoodItem>>(`/food?limit=100${category ? `&category=${category}` : ''}`),
          apiRequest<ApiListResponse<Category>>('/food/categories'),
        ]);
        const backendFoods = foodsRes.data || [];
        const allFoods = [...backendFoods, ...mockDrinksSweetsFoods];
        const filteredFoods = category
          ? category === drinksSweetsCategoryId
            ? allFoods.filter((f) =>
                [
                  drinksSweetsCategoryId,
                  ...mockDrinksSweetsCategories.map((c) => c._id),
                ].includes(f.category?._id || ''),
              )
            : allFoods.filter((f) => f.category?._id === category)
          : allFoods;

        setFoods(filteredFoods);
        setCategories([...(categoriesRes.data || []), ...mockDrinksSweetsCategories]);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [category]);

  const visibleFoods = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return foods;
    return foods.filter((f) => f.name.toLowerCase().includes(q) || f.description.toLowerCase().includes(q));
  }, [foods, search]);

  return (
    <section className="section">
      <div className="toolbar">
        <h1 style={{ margin: 0 }}>Meals</h1>
        <Link href="/guided" className="btn secondary">Help me choose</Link>
      </div>
      <div className="toolbar">
        <input placeholder="Search meals" value={search} onChange={(e) => setSearch(e.target.value)} />
        <select value={category} onChange={(e) => setCategory(e.target.value)}>
          <option value="">All Categories</option>
          {categories.map((c) => (
            <option key={c._id} value={c._id}>{c.name}</option>
          ))}
        </select>
      </div>
      {loading ? <p className="muted">Loading meals...</p> : null}
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
