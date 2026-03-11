-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create tables
create table if not exists public.books (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  author text not null,
  grade text not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.schedules (
  id uuid default uuid_generate_v4() primary key,
  grade text not null,
  day text not null,
  period int not null,
  subject text not null,
  time text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

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

-- Table for announcement views (to track unique viewers)
create table if not exists public.announcement_views (
  id uuid default uuid_generate_v4() primary key,
  announcement_id uuid references public.announcements(id) on delete cascade,
  viewer_ip text not null,
  viewed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(announcement_id, viewer_ip)
);

-- Table for likes (one like per user per announcement)
create table if not exists public.announcement_likes (
  id uuid default uuid_generate_v4() primary key,
  announcement_id uuid references public.announcements(id) on delete cascade,
  user_ip text not null,
  liked_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(announcement_id, user_ip)
);

-- Enable RLS (safe to re-run)
alter table public.books enable row level security;
alter table public.schedules enable row level security;
alter table public.announcements enable row level security;
alter table public.announcement_views enable row level security;
alter table public.announcement_likes enable row level security;

-- Drop existing policies to avoid conflicts
drop policy if exists "Public can view books" on public.books;
drop policy if exists "Public can view schedules" on public.schedules;
drop policy if exists "Public can view announcements" on public.announcements;

drop policy if exists "Admins can insert books" on public.books;
drop policy if exists "Admins can update books" on public.books;
drop policy if exists "Admins can delete books" on public.books;

drop policy if exists "Admins can insert schedules" on public.schedules;
drop policy if exists "Admins can update schedules" on public.schedules;
drop policy if exists "Admins can delete schedules" on public.schedules;

drop policy if exists "Admins can insert announcements" on public.announcements;
drop policy if exists "Admins can update announcements" on public.announcements;
drop policy if exists "Admins can delete announcements" on public.announcements;

drop policy if exists "Public can view likes" on public.announcement_likes;
drop policy if exists "Public can insert likes" on public.announcement_likes;
drop policy if exists "Public can view views" on public.announcement_views;
drop policy if exists "Public can insert views" on public.announcement_views;

-- Create policies

-- Public read access
create policy "Public can view books" on public.books for select using (true);
create policy "Public can view schedules" on public.schedules for select using (true);
create policy "Public can view announcements" on public.announcements for select using (true);

-- Admin write access (authenticated users only)
create policy "Admins can insert books" on public.books for insert with check (auth.role() = 'authenticated');
create policy "Admins can update books" on public.books for update using (auth.role() = 'authenticated');
create policy "Admins can delete books" on public.books for delete using (auth.role() = 'authenticated');

create policy "Admins can insert schedules" on public.schedules for insert with check (auth.role() = 'authenticated');
create policy "Admins can update schedules" on public.schedules for update using (auth.role() = 'authenticated');
create policy "Admins can delete schedules" on public.schedules for delete using (auth.role() = 'authenticated');

create policy "Admins can insert announcements" on public.announcements for insert with check (auth.role() = 'authenticated');
create policy "Admins can update announcements" on public.announcements for update using (auth.role() = 'authenticated');
create policy "Admins can delete announcements" on public.announcements for delete using (auth.role() = 'authenticated');

-- Public access to likes and views
create policy "Public can view likes" on public.announcement_likes for select using (true);
create policy "Public can insert likes" on public.announcement_likes for insert with check (true);

create policy "Public can view views" on public.announcement_views for select using (true);
create policy "Public can insert views" on public.announcement_views for insert with check (true);
