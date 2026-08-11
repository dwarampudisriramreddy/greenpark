-- ============================================================================
-- Green Park Family Restaurant - Customer Feedback & Reviews
-- Customers submit reviews / complaints / suggestions; admins moderate them.
-- Public can insert new feedback (but cannot self-publish) and read only
-- published, positive reviews shown on the app.
-- ============================================================================

create table if not exists public.feedback_reviews (
  id            uuid primary key default gen_random_uuid(),
  customer_name text,
  kind          text not null default 'review'
                check (kind in ('review', 'complaint', 'suggestion')),
  rating        integer not null default 5 check (rating between 1 and 5),
  message       text not null,
  contact       text,
  is_published  boolean not null default false,
  created_at    timestamptz not null default now()
);

comment on table public.feedback_reviews is
  'Customer feedback: reviews (public showcase) and complaints/suggestions (admin inbox only).';

alter table public.feedback_reviews enable row level security;

-- Everyone can read published reviews (home showcase).
drop policy if exists "feedback_reviews public read" on public.feedback_reviews;
create policy "feedback_reviews public read" on public.feedback_reviews
  for select using (is_published = true);

-- Anyone can submit feedback; never pre-published.
drop policy if exists "feedback_reviews public insert" on public.feedback_reviews;
create policy "feedback_reviews public insert" on public.feedback_reviews
  for insert with check (is_published = false and rating between 1 and 5 and message <> '');

-- Admins can see everything and moderate.
drop policy if exists "feedback_reviews admin all" on public.feedback_reviews;
create policy "feedback_reviews admin all" on public.feedback_reviews
  for all using (public.is_admin()) with check (public.is_admin());
