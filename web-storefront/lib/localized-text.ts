import type { Lang } from '@/lib/i18n';

const arabicFallbackMap: Record<string, string> = {
  'Pre-Workout Energy Bites (6 pcs)': 'لقيمات طاقة قبل التمرين (6 قطع)',
  'Energizing date and nut bites with a hint of espresso. Perfect fuel 30 minutes before your workout.': 'لقيمات تمر ومكسرات مع لمسة إسبريسو. وقود مثالي قبل التمرين بـ 30 دقيقة.',
  'Bakery bread': 'خبز المخبز',
  'Test for Norehane': 'تجربة لنورهان',
  'Rabbit test': 'اختبار رابت',
  'This was created by Mohab for testing': 'تم إنشاء هذا بواسطة مهاب للاختبار',
  'Kids Rainbow Veggie Bites': 'لقيمات خضار قوس قزح للأطفال',
  'Fun and colorful vegetable bites that kids love. Packed with hidden veggies and served with a tasty yogurt dip.': 'لقيمات خضار ملونة وممتعة يحبها الأطفال، مليئة بخضار مخفية وتقدم مع صوص زبادي لذيذ.',
  'Gut-Healing Bone Broth Soup': 'شوربة مرق العظام لصحة الأمعاء',
  'Slow-simmered bone broth with ginger, turmeric, and healing herbs. Gentle on the stomach and deeply nourishing.': 'مرق عظام مطهو ببطء مع الزنجبيل والكركم وأعشاب مفيدة. لطيف على المعدة ومغذٍ بعمق.',
  'Hormone Balance Bowl': 'وعاء توازن الهرمونات',
  'Specially designed bowl with wild-caught fish, cruciferous vegetables, and seeds to support hormonal health.': 'وعاء مصمم خصيصًا مع سمك بري وخضار صليبية وبذور لدعم صحة الهرمونات.',
  'Suhoor Sustain Plate': 'طبق سحور مشبع',
  'Specially designed for Ramadan. Slow-release carbs, protein, and healthy fats to keep you full through the fast.': 'مصمم خصيصًا لرمضان: كربوهيدرات بطيئة الامتصاص مع بروتين ودهون صحية للحفاظ على الشبع طوال الصيام.',
  'Grilled Salmon Power Bowl': 'وعاء السلمون المشوي للطاقة',
  'Wild-caught salmon fillet served with quinoa, roasted vegetables, and a lemon tahini dressing. Perfect for sustained energy and muscle recovery.': 'فيليه سلمون بري يقدم مع الكينوا وخضار مشوية وصوص طحينة بالليمون. مثالي لطاقة مستمرة وتعافي العضلات.',
  'Green Goddess Salad': 'سلطة الجرين جودِس',
  'Fresh mixed greens with avocado, cucumber, chickpeas, and our signature green goddess dressing. Light yet satisfying.': 'خضار ورقية طازجة مع أفوكادو وخيار وحمص وصوص جرين جودس الخاص بنا. خفيفة لكنها مشبعة.',
  'Protein Overnight Oats': 'شوفان البروتين الليلي',
  'Creamy overnight oats with protein powder, chia seeds, almond butter, and fresh berries. Perfect fuel for your morning.': 'شوفان ليلي كريمي مع بودرة بروتين وبذور الشيا وزبدة اللوز وتوت طازج. وقود مثالي لبداية يومك.',
  'Grilled Chicken & Quinoa': 'دجاج مشوي مع كينوا',
  'Herb-marinated grilled chicken breast with fluffy quinoa, roasted vegetables, and homemade chimichurri sauce.': 'صدر دجاج مشوي متبل بالأعشاب مع كينوا هشة وخضار مشوية وصوص تشيميتشوري منزلي.',
  'Chamomile Sleep Smoothie': 'سموثي النوم بالبابونج',
  'Calming smoothie with chamomile tea, banana, almond butter, and honey. Natural sleep support in a delicious drink.': 'سموثي مهدئ مع شاي البابونج وموز وزبدة لوز وعسل. دعم طبيعي للنوم في مشروب لذيذ.',
  'Test food': 'طعام تجريبي',
  'Daily Meals': 'الوجبات اليومية',
  'Smart Salads': 'السلطات الذكية',
  'Functional Snacks': 'سناكس وظيفية',
  'Gym Performance': 'أداء الجيم',
  'Kids Meals': 'وجبات الأطفال',
  'Digestive Comfort': 'راحة الهضم',
  'Night & Calm': 'ليل وهدوء',
  'Meal Bundles': 'باقات الوجبات',
};

function normalizeKey(text: string): string {
  return text.trim().replace(/\s+/g, ' ');
}

function arabicFallback(text?: string): string {
  if (!text) return '';
  return arabicFallbackMap[normalizeKey(text)] || '';
}

export function localizedText(lang: Lang, primary?: string, arabic?: string): string {
  if (lang === 'ar') {
    return arabic?.trim() || arabicFallback(primary) || primary?.trim() || '';
  }
  return primary?.trim() || arabic?.trim() || '';
}
