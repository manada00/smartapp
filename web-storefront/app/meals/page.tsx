'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { apiRequest } from '@/lib/api';
import { useLanguage } from '@/components/language-provider';
import { localizedText } from '@/lib/localized-text';
import type { Category, FoodItem } from '@/lib/types';

type ApiListResponse<T> = { data: T[] };

export default function MealsPage() {
  const { t, lang } = useLanguage();
  const [foods, setFoods] = useState<FoodItem[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [category, setCategory] = useState('');
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    setCategory(params.get('category') || '');
  }, []);

  useEffect(() => {
    async function load(silent = false) {
      if (!silent) {
        setLoading(true);
      }
      setError('');
      try {
        const [foodsRes, categoriesRes] = await Promise.all([
          apiRequest<ApiListResponse<FoodItem>>(`/food?limit=100${category ? `&category=${category}` : ''}`),
          apiRequest<ApiListResponse<Category>>('/food/categories'),
        ]);
        setFoods(foodsRes.data || []);
        setCategories(categoriesRes.data || []);
      } catch (e) {
        setFoods([]);
        setCategories([]);
        setError(e instanceof Error ? e.message : 'Failed to load meals.');
      } finally {
        if (!silent) {
          setLoading(false);
        }
      }
    }
    load();

    const intervalId = window.setInterval(() => {
      void load(true);
    }, 15000);

    return () => {
      window.clearInterval(intervalId);
    };
  }, [category]);

  const visibleFoods = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return foods;
    return foods.filter((f) => {
      const name = localizedText(lang, f.name, f.nameAr).toLowerCase();
      const description = localizedText(lang, f.description, f.descriptionAr).toLowerCase();
      return name.includes(q) || description.includes(q);
    });
  }, [foods, lang, search]);

  return (
    <section className="section">
      <div className="toolbar">
        <h1 style={{ margin: 0 }}>{t('mealsTitle')}</h1>
        <Link href="/guided" className="btn secondary">{t('helpMeChoose')}</Link>
      </div>
      <div className="category-visual-row">
        <div className="category-visual-card" style={{ backgroundImage: 'linear-gradient(rgba(20,20,20,.2), rgba(20,20,20,.45)), url(https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1200&q=80)' }}>
          <strong>Fresh Category Picks</strong>
          <span>Whole-food bowls, grains, greens, and protein-forward plates.</span>
        </div>
        <div className="category-visual-card" style={{ backgroundImage: 'linear-gradient(rgba(20,20,20,.2), rgba(20,20,20,.45)), url(https://images.unsplash.com/photo-1464306076886-da185f6a9d05?auto=format&fit=crop&w=1200&q=80)' }}>
          <strong>Drinks & Sweets</strong>
          <span>Healthy drinks and smart sweets with clean premium visuals.</span>
        </div>
      </div>
      <div className="toolbar">
        <input placeholder={t('searchMeals')} value={search} onChange={(e) => setSearch(e.target.value)} />
        <select value={category} onChange={(e) => setCategory(e.target.value)}>
          <option value="">{t('allCategories')}</option>
          {categories.map((c) => (
            <option key={c._id} value={c._id}>{localizedText(lang, c.name, c.nameAr)}</option>
          ))}
        </select>
      </div>
      {loading ? <p className="muted">Loading meals...</p> : null}
      {error ? <p style={{ color: '#b42318' }}>{error}</p> : null}
      {!loading && !error && visibleFoods.length === 0 ? <p className="muted">No meals available right now.</p> : null}
      <div className="grid cols-4">
        {visibleFoods.map((food) => (
          <Link key={food._id} href={`/meals/${food._id}`} className="card">
            {food.images?.[0] ? <img src={food.images[0]} alt={localizedText(lang, food.name, food.nameAr)} className="meal-image" /> : <div className="meal-image placeholder">No image</div>}
            <h3>{localizedText(lang, food.name, food.nameAr)}</h3>
            <p className="muted">{localizedText(lang, food.description, food.descriptionAr)}</p>
            <p><strong>{food.price} EGP</strong></p>
          </Link>
        ))}
      </div>
    </section>
  );
}
