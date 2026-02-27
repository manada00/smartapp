import Link from 'next/link';
import { Card } from '@/components/ui/primitives';

const controls = [
  {
    title: 'Manage Menu Items',
    description: 'Add new meals, edit nutrition info, set availability, and duplicate items.',
    href: '/menu',
    cta: 'Open Menu',
  },
  {
    title: 'Upload / Replace Food Images',
    description: 'Use Upload Image per meal so storefront and mobile app show the same visuals.',
    href: '/menu',
    cta: 'Open Image Controls',
  },
  {
    title: 'Manage Categories',
    description: 'Create and edit categories like High Protein, Keto, Weight Loss, and Kids.',
    href: '/categories',
    cta: 'Open Categories',
  },
  {
    title: 'Website Home Content',
    description: 'Control hero content, promotions, and featured meals from one backend config.',
    href: '/settings',
    cta: 'Open Website Content',
  },
  {
    title: 'Support Settings',
    description: 'Configure support channels shown to users in app and website.',
    href: '/support',
    cta: 'Open Support Config',
  },
];

export default function WebsiteManagementPage() {
  return (
    <Card>
      <h3>Website Management</h3>
      <p className="muted">This tab controls the same ecosystem used by mobile: meals, images, categories, and storefront content.</p>

      <div className="grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', marginTop: 12 }}>
        {controls.map((control) => (
          <section key={control.title} className="card">
            <h3>{control.title}</h3>
            <p className="muted">{control.description}</p>
            <Link href={control.href} className="btn btn-primary">{control.cta}</Link>
          </section>
        ))}
      </div>
    </Card>
  );
}
