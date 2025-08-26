-- ShiftOS Backend — all.sql
-- ONE place to control the "today" boundary via shift_today()
-- To use UTC instead of Africa/Lagos, change the function body to:
--   select (now() at time zone 'UTC')::date;
-- …then re-run this file.

create extension if not exists pgcrypto;

-- === "Today" helper =========================================================
create or replace function public.shift_today()
returns date
language sql
stable
as $$
  select timezone('Africa/Lagos', now())::date
$$;

-- === TABLE ==================================================================
create table if not exists public.shifts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  shift_date date not null default public.shift_today(),
  win text,
  inserted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Unique per (user_id, shift_date)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'shifts_user_id_shift_date_key'
  ) then
    alter table public.shifts
      add constraint shifts_user_id_shift_date_key unique (user_id, shift_date);
  end if;
end $$;

-- === TRIGGER: enforce auth.uid() & immutable date ===========================
create or replace function public.set_shifts_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if TG_OP = 'INSERT' then
    new.user_id := auth.uid();
    if new.shift_date is null then
      new.shift_date := public.shift_today();
    end if;
    new.inserted_at := now();
    new.updated_at := now();
  elsif TG_OP = 'UPDATE' then
    -- keep ownership & date stable
    new.user_id := old.user_id;
    new.shift_date := old.shift_date;
    new.updated_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_set_shifts_defaults on public.shifts;
create trigger trg_set_shifts_defaults
before insert or update on public.shifts
for each row execute function public.set_shifts_defaults();

-- === RLS ====================================================================
alter table public.shifts enable row level security;

drop policy if exists "Select own shifts" on public.shifts;
create policy "Select own shifts"
on public.shifts for select
using (user_id = auth.uid());

drop policy if exists "Insert own shift" on public.shifts;
create policy "Insert own shift"
on public.shifts for insert
with check (user_id = auth.uid());

drop policy if exists "Update own shift" on public.shifts;
create policy "Update own shift"
on public.shifts for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Delete own shift" on public.shifts;
create policy "Delete own shift"
on public.shifts for delete
using (user_id = auth.uid());

-- === RPC: upsert one row per (user, today) =================================
create or replace function public.upsert_today_shift(p_win text default null)
returns public.shifts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_date date := public.shift_today();
  v_row public.shifts;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.shifts (user_id, shift_date, win)
  values (v_user, v_date, p_win)
  on conflict (user_id, shift_date)
  do update set
    win = coalesce(excluded.win, public.shifts.win),
    updated_at = now()
  returning * into v_row;

  return v_row;
end;
$$;

-- Allow only signed-in users to call the RPC
revoke all on function public.upsert_today_shift(text) from public;
grant execute on function public.upsert_today_shift(text) to authenticated;
