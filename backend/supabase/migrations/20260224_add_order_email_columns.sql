alter table if exists public.orders
  add column if not exists order_id text,
  add column if not exists user_id text,
  add column if not exists user_email text,
  add column if not exists order_items jsonb,
  add column if not exists total_amount numeric,
  add column if not exists payment_method text,
  add column if not exists payment_status text,
  add column if not exists transaction_id text,
  add column if not exists payment_timestamp timestamptz,
  add column if not exists order_status text,
  add column if not exists created_at timestamptz,
  add column if not exists email_sent boolean default false,
  add column if not exists email_sent_at timestamptz,
  add column if not exists email_delivery_status text;

create unique index if not exists orders_order_id_unique_idx on public.orders(order_id);
