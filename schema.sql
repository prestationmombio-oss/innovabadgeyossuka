-- InnovaBadge v2 (multi-écoles) — à exécuter dans Supabase > SQL Editor
-- ⚠️ SI VOUS AVIEZ LA v1 : exécutez d'abord cette ligne (efface les données de test) :
-- drop view if exists presences_jour; drop table if exists scans, students cascade;

create extension if not exists pgcrypto;

create table if not exists schools (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  logo_url text,
  heure_debut time not null default '07:30',   -- au-delà : retard
  created_at timestamptz not null default now()
);

create table if not exists profiles (            -- qui a accès à quelle école
  user_id uuid primary key references auth.users(id) on delete cascade,
  school_id uuid not null references schools(id) on delete cascade,
  role text not null default 'surveillant' check (role in ('direction','surveillant'))
);

create table if not exists persons (             -- élèves, professeurs, administration
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references schools(id) on delete cascade,
  type text not null check (type in ('eleve','prof','admin')),
  matricule text not null,
  nom text not null,
  prenom text not null default '',
  groupe text not null default '',               -- classe | discipline | fonction
  niveau text,                                   -- élèves uniquement (6ème, 5ème…)
  qr_token text unique not null default encode(gen_random_bytes(6),'hex'),
  actif boolean not null default true,
  created_at timestamptz not null default now(),
  unique (school_id, matricule)
);

create table if not exists scans (
  id uuid primary key,                           -- généré par le téléphone (anti-doublons)
  school_id uuid not null references schools(id) on delete cascade,
  person_id uuid not null references persons(id) on delete cascade,
  type text not null check (type in ('entree','sortie')),
  scanned_at timestamptz not null,
  device text,
  created_at timestamptz not null default now()
);
create index if not exists scans_school_date on scans (school_id, scanned_at desc);
create index if not exists scans_person on scans (person_id, scanned_at desc);

create or replace function my_school() returns uuid language sql stable security definer set search_path=public as
$$ select school_id from profiles where user_id = auth.uid() $$;
create or replace function my_role() returns text language sql stable security definer set search_path=public as
$$ select role from profiles where user_id = auth.uid() $$;

alter table schools enable row level security;
alter table profiles enable row level security;
alter table persons enable row level security;
alter table scans enable row level security;

create policy p_prof_sel on profiles for select to authenticated using (user_id = auth.uid());
create policy p_sch_sel on schools for select to authenticated using (id = my_school());
create policy p_sch_upd on schools for update to authenticated using (id = my_school() and my_role()='direction') with check (id = my_school());
create policy p_per_sel on persons for select to authenticated using (school_id = my_school());
create policy p_per_ins on persons for insert to authenticated with check (school_id = my_school() and my_role()='direction');
create policy p_per_upd on persons for update to authenticated using (school_id = my_school() and my_role()='direction') with check (school_id = my_school());
create policy p_per_del on persons for delete to authenticated using (school_id = my_school() and my_role()='direction');
create policy p_scn_sel on scans for select to authenticated using (school_id = my_school());
create policy p_scn_ins on scans for insert to authenticated with check (school_id = my_school());

-- ===== Outils InnovaData : créer une école / ajouter un compte (à lancer dans le SQL Editor) =====
create or replace function onboard_school(p_nom text, p_email text, p_role text default 'direction') returns uuid
language plpgsql security definer set search_path=public as $$
declare sid uuid; uid uuid;
begin
  select id into uid from auth.users where lower(email)=lower(p_email);
  if uid is null then raise exception 'Créez d''abord l''utilisateur % (Authentication > Users)', p_email; end if;
  insert into schools(nom) values (p_nom) returning id into sid;
  insert into profiles(user_id,school_id,role) values (uid,sid,p_role)
    on conflict (user_id) do update set school_id=excluded.school_id, role=excluded.role;
  return sid;
end $$;

create or replace function link_user(p_school uuid, p_email text, p_role text default 'surveillant') returns void
language plpgsql security definer set search_path=public as $$
declare uid uuid;
begin
  select id into uid from auth.users where lower(email)=lower(p_email);
  if uid is null then raise exception 'Créez d''abord l''utilisateur %', p_email; end if;
  insert into profiles(user_id,school_id,role) values (uid,p_school,p_role)
    on conflict (user_id) do update set school_id=excluded.school_id, role=excluded.role;
end $$;
revoke execute on function onboard_school(text,text,text), link_user(uuid,text,text) from public, anon, authenticated;
