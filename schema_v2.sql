-- Add columns for Announcements V2
alter table public.announcements 
add column if not exists images text[] default '{}',
add column if not exists reactions jsonb default '{}'::jsonb;

-- Add columns for Books V2
alter table public.books 
add column if not exists file_url text;

-- Create Storage Buckets (if not exists)
insert into storage.buckets (id, name, public) 
values ('school-content', 'school-content', true)
on conflict (id) do nothing;

-- Storage Policies
-- 1. Public can view all content
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'school-content' );

-- 2. Authenticated admins can upload/update/delete
create policy "Admin Upload"
on storage.objects for insert
with check ( bucket_id = 'school-content' and auth.role() = 'authenticated' );

create policy "Admin Update"
on storage.objects for update
using ( bucket_id = 'school-content' and auth.role() = 'authenticated' );

create policy "Admin Delete"
on storage.objects for delete
using ( bucket_id = 'school-content' and auth.role() = 'authenticated' );

-- Function for reacting (increment counter)
create or replace function increment_reaction(row_id uuid, reaction_type text)
returns void as $$
begin
  update public.announcements
  set reactions = jsonb_set(
    coalesce(reactions, '{}'::jsonb),
    array[reaction_type],
    (coalesce((reactions->>reaction_type)::int, 0) + 1)::text::jsonb
  )
  where id = row_id;
end;
$$ language plpgsql security definer;
