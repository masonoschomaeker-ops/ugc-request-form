-- Run once in a NEW Supabase project's SQL Editor, as the project owner.
begin;
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create table private.ugc_creators (
 user_id uuid primary key references auth.users(id) on delete cascade
);
revoke all on private.ugc_creators from public, anon, authenticated;
create table public.ugc_orders (
 id uuid primary key default gen_random_uuid(),
 data jsonb not null check (jsonb_typeof(data)='object' and octet_length(data::text)<=15000),
 status text not null default 'New' check (status in ('New','Reviewing','Accepted','In progress','Completed','Declined')),
 created timestamptz not null default now()
);
alter table public.ugc_orders enable row level security;
revoke all on public.ugc_orders from public, anon, authenticated;
grant select on public.ugc_orders to authenticated;
grant update (status) on public.ugc_orders to authenticated;
create function public.is_creator() returns boolean
language sql stable security definer set search_path = ''
as $$select exists(select 1 from private.ugc_creators where user_id=(select auth.uid()))$$;
revoke all on function public.is_creator() from public, anon, authenticated;
grant execute on function public.is_creator() to authenticated;
create policy creator_read on public.ugc_orders for select to authenticated
 using ((select public.is_creator()));
create policy creator_update on public.ugc_orders for update to authenticated
 using ((select public.is_creator())) with check ((select public.is_creator()));
-- Customers can execute this function but cannot read orders or insert directly.
-- Only an explicit allowlist of fields is stored; status/id/time are server-owned.
create function public.submit_ugc_order(payload jsonb) returns uuid
language plpgsql security definer set search_path = '' as $$
declare clean jsonb := '{}'::jsonb; item text; value text; new_id uuid;
begin
 if payload is null or jsonb_typeof(payload)<>'object' or octet_length(payload::text)>15000 then
  raise exception 'Invalid request';
 end if;
 foreach item in array array['name','size','font','theme','contact','payment','ugc'] loop
  if jsonb_typeof(payload->item) is distinct from 'string' or length(trim(payload->>item))=0 or length(payload->>item)>2000 then
   raise exception 'Required field invalid: %',item;
  end if;
 end loop;
 foreach item in array array['name','size','font','theme','contact','payment','ugc','reference','necklace','jumbo','beaded','fastpass','upload','notes'] loop
  if payload ? item then
   if jsonb_typeof(payload->item) is distinct from 'string' or length(payload->>item)>2000 then raise exception 'Invalid field'; end if;
   clean := clean || jsonb_build_object(item,trim(payload->>item));
  end if;
 end loop;
 if clean->>'necklace' is null or clean->>'necklace' not in ('Yes','No') then raise exception 'Choose necklace type'; end if;
 if clean->>'necklace'='No' then clean := clean-'jumbo'-'beaded'; end if;
 insert into public.ugc_orders(data) values(clean) returning id into new_id;
 return new_id;
end $$;
revoke all on function public.submit_ugc_order(jsonb) from public, anon, authenticated;
grant execute on function public.submit_ugc_order(jsonb) to anon, authenticated;
commit;
