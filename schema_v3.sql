-- Скрипт синхронизации базы данных (Версия 3)

-- 1. Таблица объявлений
create table if not exists public.announcements (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  content text not null,
  date date not null,
  images text[] default '{}',
  videos text[] default '{}',
  views_count int default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Таблица для уникальных просмотров (по IP)
create table if not exists public.announcement_views (
  id uuid default uuid_generate_v4() primary key,
  announcement_id uuid references public.announcements(id) on delete cascade,
  viewer_ip text not null,
  viewed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(announcement_id, viewer_ip)
);

-- 3. Таблица для лайков (по IP)
create table if not exists public.announcement_likes (
  id uuid default uuid_generate_v4() primary key,
  announcement_id uuid references public.announcements(id) on delete cascade,
  user_ip text not null,
  liked_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(announcement_id, user_ip)
);

-- 4. Политики безопасности (RLS)
alter table public.announcements enable row level security;
alter table public.announcement_views enable row level security;
alter table public.announcement_likes enable row level security;

-- Анонимные пользователи могут смотреть и ставить лайки
drop policy if exists "Public Read" on public.announcements;
create policy "Public Read" on public.announcements for select using (true);

drop policy if exists "Public View Insert" on public.announcement_views;
create policy "Public View Insert" on public.announcement_views for insert with check (true);
create policy "Public View Read" on public.announcement_views for select using (true);

drop policy if exists "Public Like Insert" on public.announcement_likes;
create policy "Public Like Insert" on public.announcement_likes for insert with check (true);
drop policy if exists "Public Like Delete" on public.announcement_likes;
create policy "Public Like Delete" on public.announcement_likes for delete using (true);
create policy "Public Like Read" on public.announcement_likes for select using (true);

-- Админ может всё
create policy "Admin All" on public.announcements for all using (auth.role() = 'authenticated');

-- 5. Настройка Хранилища (Storage)
-- Инструкция: Если bucket 'school-content' не создан, создайте его в панели Supabase и сделайте PUBLIC.
-- Либо выполните этот SQL (требует прав админа):
insert into storage.buckets (id, name, public)
values ('school-content', 'school-content', true)
on conflict (id) do nothing;

create policy "Public View" on storage.objects for select using ( bucket_id = 'school-content' );
create policy "Admin Upload" on storage.objects for insert with check ( bucket_id = 'school-content' );
create policy "Admin Update" on storage.objects for update using ( bucket_id = 'school-content' );
create policy "Admin Delete" on storage.objects for delete using ( bucket_id = 'school-content' );
