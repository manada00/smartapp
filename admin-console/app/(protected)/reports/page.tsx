import { fetchAdmin } from '@/lib/backend';
import { ReportsView } from '@/components/reports/reports-view';

export default async function ReportsPage() {
  const reportRes = await fetchAdmin('/api/v1/admin/reports?range=daily');

  const initialData = reportRes?.data || {
    range: 'daily',
    from: new Date().toISOString(),
    to: new Date().toISOString(),
    totalSales: 0,
    totalOrders: 0,
    returnedOrders: 0,
    casesOrMessagesSent: 0,
    repeatPurchaseRate: 0,
    topItems: [],
    lowPerformanceItems: [],
    salesByPeriod: [],
  };

  return <ReportsView initialData={initialData} />;
}
