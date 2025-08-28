-- all.sql — ShiftOS minimal backend (public.shifts + RLS + RPC)

-- 1) Table
create table if not exists public.shifts (
  id           bigserial primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  shift_date   date not null default (current_date),
  win          text not null default '',
  inserted_at  timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (user_id, shift_date)
);

-- 2) Updated-at trigger
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists set_updated_at_on_shifts on public.shifts;
create trigger set_updated_at_on_shifts
before update on public.shifts
for each row execute function public.set_updated_at();

-- 3) RLS
alter table public.shifts enable row level security;

-- Policy: read own rows
drop policy if exists "shifts_read_own" on public.shifts;
create policy "shifts_read_own"
on public.shifts
for select
using (auth.uid() = user_id);

-- Policy: insert own rows
drop policy if exists "shifts_insert_own" on public.shifts;
create policy "shifts_insert_own"
on public.shifts
for insert
with check (auth.uid() = user_id);

-- Policy: update own rows
drop policy if exists "shifts_update_own" on public.shifts;
create policy "shifts_update_own"
on public.shifts
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- (No delete policy -> deletes are denied by default)

-- 4) RPC: upsert_today_shift(p_win)
create or replace function public.upsert_today_shift(p_win text)
returns public.shifts
language plpgsql
as $$
declare
  v_row public.shifts;
begin
  insert into public.shifts (user_id, shift_date, win)
  values (auth.uid(), current_date, coalesce(p_win, ''))
  on conflict (user_id, shift_date)
  do update set win = excluded.win, updated_at = now()
  returning * into v_row;

  return v_row;
end;
$$;

-- Grant execute to logged-in users
grant execute on function public.upsert_today_shift(text) to authenticated;
