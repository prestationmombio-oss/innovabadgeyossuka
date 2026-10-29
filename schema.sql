-- InnovaBadge : à exécuter dans Supabase > SQL Editor
create extension if not exists pgcrypto;

create table if not exists students (
  id uuid primary key default gen_random_uuid(),
  matricule text unique not null,
  nom text not null,
  prenom text not null default '',
  classe text not null default '',
  qr_token text unique not null default encode(gen_random_bytes(6),'hex'),
  actif boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists scans (
  id uuid primary key,                       -- généré par le téléphone (évite les doublons à la synchro)
  student_id uuid not null references students(id) on delete cascade,
  type text not null check (type in ('entree','sortie')),
  scanned_at timestamptz not null,
  device text,
  created_at timestamptz not null default now()
);
create index if not exists scans_date_idx on scans (scanned_at desc);
create index if not exists scans_student_idx on scans (student_id, scanned_at desc);

alter table students enable row level security;
alter table scans enable row level security;
create policy "personnel_students" on students for all to authenticated using (true) with check (true);
create policy "personnel_scans" on scans for all to authenticated using (true) with check (true);

-- Vue pratique pour la direction
create or replace view presences_jour as
select s.classe, s.nom, s.prenom, sc.type, sc.scanned_at
from scans sc join students s on s.id = sc.student_id
where sc.scanned_at::date = current_date order by sc.scanned_at desc;
