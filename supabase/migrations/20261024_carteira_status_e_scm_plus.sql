-- Estrutura apenas. Os dados (status das empresas, novas empresas e carteira SCM+)
-- foram aplicados diretamente no Supabase e não ficam neste repositório público.
-- Gestão de carteira: cinzar canceladas, novas empresas LGPD e carteira SCM+ (24/10/2026)
-- Somente aditivo: nenhum progresso (checklist_items / recurring_deliverables) é alterado.

-- 1) Status da carteira (coluna nova; a sincronização da planilha não a sobrescreve)
alter table public.companies add column if not exists status_carteira text not null default 'ativo';
alter table public.companies drop constraint if exists companies_status_carteira_chk;
alter table public.companies add constraint companies_status_carteira_chk check (status_carteira in ('ativo','cancelada','migrada_scm'));

-- 3) Carteira SCM+ (tabelas novas)
create table if not exists public.scm_companies (
  id bigserial primary key,
  cnpj text unique not null,
  razao_social text not null,
  analista_responsavel text,
  situacao text default 'ATIVO',
  condicao text default '',
  dpo_nome text default '',
  dpo_contato text default '',
  is_nova boolean default false,
  status_carteira text not null default 'ativo' check (status_carteira in ('ativo','cancelada')),
  created_at timestamptz default now()
);
create table if not exists public.scm_checklist_items (
  id bigserial primary key,
  company_id bigint not null references public.scm_companies(id) on delete cascade,
  grupo text,
  item_chave text not null,
  status text default 'nao',
  pendencia text default '',
  data date,
  anotacoes text default '',
  updated_at timestamptz default now(),
  unique (company_id, item_chave)
);
alter table public.scm_companies enable row level security;
alter table public.scm_checklist_items enable row level security;
drop policy if exists auth_all on public.scm_companies;
drop policy if exists auth_all on public.scm_checklist_items;
create policy auth_all on public.scm_companies for all to authenticated using (true) with check (true);
create policy auth_all on public.scm_checklist_items for all to authenticated using (true) with check (true);
revoke all on public.scm_companies, public.scm_checklist_items from anon;
grant select, insert, update, delete on public.scm_companies, public.scm_checklist_items to authenticated;
grant usage, select on sequence public.scm_companies_id_seq, public.scm_checklist_items_id_seq to authenticated;
