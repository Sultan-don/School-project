-- ВЫПОЛНИТЕ ЭТОТ КОД В SUPABASE SQL EDITOR

-- 1. Добавляем недостающие колонки в таблицу объявлений
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS images text[] DEFAULT '{}';
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS videos text[] DEFAULT '{}';

-- 2. Если таблиц для статистики еще нет, создаем их
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

-- 3. Включаем RLS
alter table public.announcement_views enable row level security;
alter table public.announcement_likes enable row level security;

-- 4. Политики доступа
drop policy if exists "Public View Insert" on public.announcement_views;
create policy "Public View Insert" on public.announcement_views for insert with check (true);
create policy "Public View Read" on public.announcement_views for select using (true);

drop policy if exists "Public Like Insert" on public.announcement_likes;
create policy "Public Like Insert" on public.announcement_likes for insert with check (true);
drop policy if exists "Public Like Delete" on public.announcement_likes;
create policy "Public Like Delete" on public.announcement_likes for delete using (true);
create policy "Public Like Read" on public.announcement_likes for select using (true);
