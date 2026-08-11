-- ============================================================================
-- Green Park Family Restaurant - Initial Schema
-- Rajanagaram, Rajahmundry, Andhra Pradesh
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Utility functions
-- ----------------------------------------------------------------------------

-- Automatically update the updated_at column on row changes
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- 2. Tables
-- ----------------------------------------------------------------------------

-- Restaurant profile (single row)
create table if not exists public.restaurant_info (
  id             bigint primary key generated always as identity,
  name           text not null default 'Green Park Family Restaurant',
  tagline        text,
  about          text,
  address        text,
  phone          text,
  whatsapp       text,
  email          text,
  opening_hours  jsonb,
  maps_url       text,
  instagram_url  text,
  facebook_url   text,
  logo_url       text,
  hero_image_url text,
  updated_at     timestamptz not null default now()
);

-- Menu categories
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text,
  icon        text,
  image_url   text,
  sort_order  integer not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Menu items
create table if not exists public.menu_items (
  id           uuid primary key default gen_random_uuid(),
  category_id  uuid references public.categories(id) on delete cascade,
  name         text not null,
  description  text,
  price        numeric(10,2) not null,
  image_url    text,
  is_veg       boolean not null default true,
  is_spicy     boolean not null default false,
  is_bestseller boolean not null default false,
  is_available boolean not null default true,
  is_active    boolean not null default true,
  sort_order   integer not null default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Offers
create table if not exists public.offers (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text,
  banner_url  text,
  valid_from  date,
  valid_until date,
  terms       text,
  is_featured boolean not null default false,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Posts / updates
create table if not exists public.posts (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  description  text,
  category     text,
  is_featured  boolean not null default false,
  is_published boolean not null default true,
  published_at timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Multiple images per post
create table if not exists public.post_images (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid references public.posts(id) on delete cascade,
  image_url  text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- Gallery images
create table if not exists public.gallery_images (
  id           uuid primary key default gen_random_uuid(),
  title        text,
  category     text,
  image_url    text not null,
  is_published boolean not null default true,
  sort_order   integer not null default 0,
  created_at   timestamptz not null default now()
);

-- Registered administrators (maps an auth user to an admin)
create table if not exists public.admins (
  id         uuid primary key references auth.users(id) on delete cascade,
  email      text not null unique,
  full_name  text,
  created_at timestamptz not null default now()
);

-- True when the calling user is a registered restaurant admin
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.admins a where a.id = auth.uid()
  );
$$;

-- ----------------------------------------------------------------------------
-- 3. updated_at triggers
-- ----------------------------------------------------------------------------

drop trigger if exists trg_restaurant_info_updated on public.restaurant_info;
create trigger trg_restaurant_info_updated
  before update on public.restaurant_info
  for each row execute function public.set_updated_at();

drop trigger if exists trg_categories_updated on public.categories;
create trigger trg_categories_updated
  before update on public.categories
  for each row execute function public.set_updated_at();

drop trigger if exists trg_menu_items_updated on public.menu_items;
create trigger trg_menu_items_updated
  before update on public.menu_items
  for each row execute function public.set_updated_at();

drop trigger if exists trg_offers_updated on public.offers;
create trigger trg_offers_updated
  before update on public.offers
  for each row execute function public.set_updated_at();

drop trigger if exists trg_posts_updated on public.posts;
create trigger trg_posts_updated
  before update on public.posts
  for each row execute function public.set_updated_at();

-- ----------------------------------------------------------------------------
-- 4. Row Level Security
-- ----------------------------------------------------------------------------

alter table public.restaurant_info enable row level security;
alter table public.categories         enable row level security;
alter table public.menu_items         enable row level security;
alter table public.offers             enable row level security;
alter table public.posts              enable row level security;
alter table public.post_images        enable row level security;
alter table public.gallery_images     enable row level security;
alter table public.admins             enable row level security;

-- restaurant_info: everyone can read, only admins write
drop policy if exists "restaurant_info public read" on public.restaurant_info;
create policy "restaurant_info public read" on public.restaurant_info
  for select to anon, authenticated using (true);

drop policy if exists "restaurant_info admin write" on public.restaurant_info;
create policy "restaurant_info admin write" on public.restaurant_info
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- categories: customers see active only
drop policy if exists "categories public read" on public.categories;
create policy "categories public read" on public.categories
  for select to anon, authenticated
  using (is_active = true or public.is_admin());

drop policy if exists "categories admin write" on public.categories;
create policy "categories admin write" on public.categories
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- menu_items: customers see active only
drop policy if exists "menu_items public read" on public.menu_items;
create policy "menu_items public read" on public.menu_items
  for select to anon, authenticated
  using (is_active = true or public.is_admin());

drop policy if exists "menu_items admin write" on public.menu_items;
create policy "menu_items admin write" on public.menu_items
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- offers: customers see active + within validity window
drop policy if exists "offers public read" on public.offers;
create policy "offers public read" on public.offers
  for select to anon, authenticated
  using (
    (is_active = true and (valid_until is null or valid_until >= current_date) and (valid_from is null or valid_from <= current_date))
    or public.is_admin()
  );

drop policy if exists "offers admin write" on public.offers;
create policy "offers admin write" on public.offers
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- posts: customers see published posts (published_at set and not in the future)
drop policy if exists "posts public read" on public.posts;
create policy "posts public read" on public.posts
  for select to anon, authenticated
  using (
    (is_published = true and (published_at is null or published_at <= now()))
    or public.is_admin()
  );

drop policy if exists "posts admin write" on public.posts;
create policy "posts admin write" on public.posts
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- post_images: public read
drop policy if exists "post_images public read" on public.post_images;
create policy "post_images public read" on public.post_images
  for select to anon, authenticated using (true);

drop policy if exists "post_images admin write" on public.post_images;
create policy "post_images admin write" on public.post_images
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- gallery_images: customers see published only
drop policy if exists "gallery_images public read" on public.gallery_images;
create policy "gallery_images public read" on public.gallery_images
  for select to anon, authenticated
  using (is_published = true or public.is_admin());

drop policy if exists "gallery_images admin write" on public.gallery_images;
create policy "gallery_images admin write" on public.gallery_images
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- admins: only admins can read/write the admins table
drop policy if exists "admins admin select" on public.admins;
create policy "admins admin select" on public.admins
  for select to authenticated using (public.is_admin());

drop policy if exists "admins admin insert" on public.admins;
create policy "admins admin insert" on public.admins
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admins admin update" on public.admins;
create policy "admins admin update" on public.admins
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins admin delete" on public.admins;
create policy "admins admin delete" on public.admins
  for delete to authenticated using (public.is_admin());

-- ----------------------------------------------------------------------------
-- 5. Storage buckets (public read, admin write)
-- ----------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('menu-images',      'menu-images',      true, 5242880, array['image/jpeg','image/png','image/webp']),
  ('offer-banners',    'offer-banners',    true, 5242880, array['image/jpeg','image/png','image/webp']),
  ('post-images',      'post-images',      true, 5242880, array['image/jpeg','image/png','image/webp']),
  ('gallery-images',   'gallery-images',   true, 5242880, array['image/jpeg','image/png','image/webp']),
  ('restaurant-images','restaurant-images',true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

-- Storage: public read for everyone on these buckets
drop policy if exists "public image read" on storage.objects;
create policy "public image read" on storage.objects
  for select to anon, authenticated
  using (bucket_id in ('menu-images','offer-banners','post-images','gallery-images','restaurant-images'));

-- Storage: only admins can upload / modify / delete
drop policy if exists "admin image write" on storage.objects;
create policy "admin image write" on storage.objects
  for insert to authenticated
  with check (
    bucket_id in ('menu-images','offer-banners','post-images','gallery-images','restaurant-images')
    and public.is_admin()
  );

drop policy if exists "admin image update" on storage.objects;
create policy "admin image update" on storage.objects
  for update to authenticated
  using (
    bucket_id in ('menu-images','offer-banners','post-images','gallery-images','restaurant-images')
    and public.is_admin()
  )
  with check (
    bucket_id in ('menu-images','offer-banners','post-images','gallery-images','restaurant-images')
    and public.is_admin()
  );

drop policy if exists "admin image delete" on storage.objects;
create policy "admin image delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id in ('menu-images','offer-banners','post-images','gallery-images','restaurant-images')
    and public.is_admin()
  );

-- ----------------------------------------------------------------------------
-- 6. Default restaurant profile
-- ----------------------------------------------------------------------------

insert into public.restaurant_info (name, tagline, about, address, phone, whatsapp, email, opening_hours, maps_url, instagram_url, facebook_url)
values (
  'Green Park Family Restaurant',
  'The Taste of Andhra, in the Heart of Rajahmundry',
  E'Green Park Family Restaurant has been a beloved dining destination in Rajanagaram since 2005. We bring together the rich, bold flavours of Andhra cuisine with a carefully curated multi-cuisine menu that families love.\n\nFrom our signature dum biryanis and wood-fired tandoori specialities to the freshest coastal seafood and a full range of vegetarian delights, every dish is prepared with authentic ingredients and a tradition of warm hospitality.\n\nWhether you are hosting a family dinner, a celebration, or simply enjoying a quiet meal, Green Park is your home away from home.',
  'Main Road, Rajanagaram, East Godavari District, Rajahmundry, Andhra Pradesh 533294',
  '+91 98765 43210',
  '+91 98765 43210',
  'hello@greenparkrestaurant.in',
  '{"sunday":{"open":"11:00 AM","close":"11:00 PM"},"monday":{"open":"11:00 AM","close":"11:00 PM"},"tuesday":{"open":"11:00 AM","close":"11:00 PM"},"wednesday":{"open":"11:00 AM","close":"11:00 PM"},"thursday":{"open":"11:00 AM","close":"11:00 PM"},"friday":{"open":"11:00 AM","close":"11:00 PM"},"saturday":{"open":"11:00 AM","close":"11:00 PM"}}',
  'https://www.google.com/maps/search/?api=1&query=Green+Park+Family+Restaurant+Rajanagaram+Rajahmundry',
  'https://www.instagram.com/greenparkrestaurant',
  'https://www.facebook.com/greenparkrestaurant'
)
on conflict do nothing;
