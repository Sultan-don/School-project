-- СВОДНЫЙ SQL СКРИПТ ДЛЯ ОБЪЯВЛЕНИЙ (МЕДИА, СТАТИСТИКА, ЛОКАЛИЗАЦИЯ)
-- Выполните этот код в Supabase SQL Editor

-- 1. Добавляем колонки для медиа (если их нет)
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS images text[] DEFAULT '{}';
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS videos text[] DEFAULT '{}';

-- 2. Добавляем колонки для локализации (RU/UZ/EN)
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS title_uz TEXT;
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS title_en TEXT;
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS content_uz TEXT;
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS content_en TEXT;

-- 3. Создаем таблицы для статистики (просмотры и лайки)
create table if not exists public.announcement_views (
  id uuid default uuid_generate_v4() primary key,
  announcement_id uuid references public.announcements(id) on delete cascade,
  viewer_ip text not null,
  viewed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(announcement_id, viewer_ip)
);

create table if not exists public.announcement_likes (
  id uuid default uuid_generate_v4() primary key,
  announcement_id uuid references public.announcements(id) on delete cascade,
  user_ip text not null,
  liked_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(announcement_id, user_ip)
);

-- 4. Включаем Row Level Security (RLS)
alter table public.announcement_views enable row level security;
alter table public.announcement_likes enable row level security;

-- 5. Настраиваем политики доступа (разрешаем публичный сбор статистики)
drop policy if exists "Public View Insert" on public.announcement_views;
create policy "Public View Insert" on public.announcement_views for insert with check (true);

drop policy if exists "Public View Read" on public.announcement_views;
create policy "Public View Read" on public.announcement_views for select using (true);

drop policy if exists "Public Like Insert" on public.announcement_likes;
create policy "Public Like Insert" on public.announcement_likes for insert with check (true);

drop policy if exists "Public Like Delete" on public.announcement_likes;
create policy "Public Like Delete" on public.announcement_likes for delete using (true);

drop policy if exists "Public Like Read" on public.announcement_likes;
create policy "Public Like Read" on public.announcement_likes for select using (true);
