export const kpis = [
  { title: 'Total Orders Today', value: '2,481', change: '+8.1%' },
  { title: 'Revenue Today', value: '$42,380', change: '+5.4%' },
  { title: 'Active Users', value: '14,927', change: '+2.2%' },
  { title: 'Pending Orders', value: '63', change: '-1.9%' },
  { title: 'Failed Payments', value: '17', change: '-0.4%' },
  { title: 'Low Stock Items', value: '29', change: '+3.0%' },
];

export const orders = [
  { id: 'ORD-1001', customer: 'Sarah Ahmed', status: 'Preparing', payment: 'Card', total: '$27.90', createdAt: '10:22' },
  { id: 'ORD-1002', customer: 'Rami Ali', status: 'Pending', payment: 'Wallet', total: '$13.20', createdAt: '10:17' },
  { id: 'ORD-1003', customer: 'Nora Samir', status: 'Out for delivery', payment: 'Cash', total: '$34.50', createdAt: '10:03' },
  { id: 'ORD-1004', customer: 'Mona Fares', status: 'Completed', payment: 'Card', total: '$19.40', createdAt: '09:55' },
];

export const meals = [
  { name: 'Greek Chicken Quinoa', category: 'High Protein', tags: ['Energy:4', 'Sleep:1', 'Satiety:3'], price: '$12.90', stock: 'In Stock' },
  { name: 'Salmon Avocado Bowl', category: 'Omega+', tags: ['Energy:3', 'Sleep:2', 'Satiety:4'], price: '$15.20', stock: 'Low' },
  { name: 'Turkey Sweet Potato', category: 'Recovery', tags: ['Energy:4', 'Sleep:2', 'Satiety:4'], price: '$13.80', stock: 'Out' },
];

export const tickets = [
  { id: 'T-2198', subject: 'Order arrived cold', status: 'Open', priority: 'High', assignee: 'Mariam S.' },
  { id: 'T-2197', subject: 'Refund not processed', status: 'Pending', priority: 'Medium', assignee: 'Ahmed K.' },
  { id: 'T-2196', subject: 'App coupon issue', status: 'Resolved', priority: 'Low', assignee: 'Lina H.' },
];
