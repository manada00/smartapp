'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { apiRequest } from '@/lib/api';
import { useLanguage } from '@/components/language-provider';
import { localizedText } from '@/lib/localized-text';
import { storage } from '@/lib/storage';
import type { CartItem, FoodItem } from '@/lib/types';

type ApiItemResponse<T> = { data: T };

function scoreEntries(food: FoodItem, t: (key: string) => string) {
  return [
    { emoji: '⚡', label: t('smartScoreEnergy'), score: food.functionalScores.energyStability },
    { emoji: '😊', label: t('smartScoreSatiety'), score: food.functionalScores.satiety },
    { emoji: '📉', label: t('smartScoreWeightLoss'), score: food.functionalScores.insulinImpact, isInverted: true },
    { emoji: '📊', label: t('smartScoreInsulinStability'), score: food.functionalScores.insulinImpact, isInverted: true },
    { emoji: '🫄', label: t('smartScoreDigestiveEase'), score: food.functionalScores.digestionEase },
    { emoji: '💪', label: t('smartScoreMuscleRecovery'), score: food.functionalScores.workoutSupport },
    { emoji: '😴', label: t('smartScoreSleepFriendly'), score: food.functionalScores.sleepFriendly },
    { emoji: '🧠', label: t('smartScoreCravingControl'), score: food.functionalScores.focusSupport },
  ];
}

function getBarTone(score: number, isInverted?: boolean) {
  const effective = isInverted ? 6 - score : score;
  if (effective >= 4) return 'good';
  if (effective === 3) return 'medium';
  return 'low';
}

export default function MealDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { lang, t } = useLanguage();
  const [food, setFood] = useState<FoodItem | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadFood() {
      setLoading(true);
      try {
        const response = await apiRequest<ApiItemResponse<FoodItem>>(`/food/${params.id}`);
        setFood(response.data);
      } catch {
        setFood(null);
      } finally {
        setLoading(false);
      }
    }
    if (params.id) loadFood();
  }, [params.id]);

  function addToCart() {
    if (!food) return;
    const localizedName = localizedText(lang, food.name, food.nameAr) || food.name;
    const current = storage.getCart<CartItem>();
    const existing = current.find((item) => item.id === food._id);
    const next = existing
      ? current.map((item) => (item.id === food._id ? { ...item, quantity: item.quantity + 1 } : item))
      : [...current, { id: food._id, name: localizedName, price: food.price, quantity: 1 }];
    storage.setCart(next);
    router.push('/cart');
  }

  if (loading) return <p className="muted">Loading meal...</p>;
  if (!food) return <p className="muted">Meal not found.</p>;

  const displayName = localizedText(lang, food.name, food.nameAr);
  const displayDescription = localizedText(lang, food.description, food.descriptionAr);

  return (
    <section className="section">
      {food.images?.[0] ? <img src={food.images[0]} alt={displayName} className="meal-hero-image" /> : <div className="meal-hero-image placeholder">No image available</div>}
      <h1>{displayName}</h1>
      <p className="muted">{displayDescription}</p>
      <p><strong>{food.price} EGP</strong></p>
      <button className="btn" onClick={addToCart}>{t('addToCart')}</button>

      <div className="section">
        <h2>{t('smartScore')}</h2>
        <div className="smartscore-card">
          {scoreEntries(food, t).map((item) => (
            <div className="smartscore-row" key={item.label}>
              <span className="score-emoji">{item.emoji}</span>
              <span className="score-label">{item.label}</span>
              <div className="score-bars">
                {Array.from({ length: 5 }).map((_, index) => (
                  <span
                    key={index}
                    className={`score-bar ${index < item.score ? `filled ${getBarTone(item.score, item.isInverted)}` : ''}`}
                  />
                ))}
              </div>
              <strong>{item.score}/5</strong>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
