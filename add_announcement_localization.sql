-- Add localization columns for Announcements
alter table public.announcements 
add column if not exists title_uz text,
add column if not exists title_en text,
add column if not exists content_uz text,
add column if not exists content_en text;

comment on column public.announcements.title_uz is 'Title in Uzbek';
comment on column public.announcements.title_en is 'Title in English';
comment on column public.announcements.content_uz is 'Content in Uzbek';
comment on column public.announcements.content_en is 'Content in English';
