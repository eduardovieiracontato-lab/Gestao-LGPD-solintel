-- ============================================================
--  Painel de Gestao LGPD - Solintel  |  schema.sql (Supabase/Postgres)
--  Ferramenta interna: acesso liberado via chave anon (RLS permissiva).
-- ============================================================

-- ---------- TABELAS ----------
create table if not exists public.companies (
  id                    integer primary key,
  cnpj                  text,
  razao_social          text not null,
  analista_responsavel  text default 'ISABELLA FARINA',
  situacao              text default 'ATIVO',
  condicao              text default '',
  dpo_nome              text default '',
  dpo_contato           text default '',
  is_nova               boolean default false,
  emails                text[] default array[]::text[],
  created_at            timestamptz default now()
);

create table if not exists public.analysts (
  id    bigint generated always as identity primary key,
  nome  text unique not null
);

create table if not exists public.checklist_items (
  id          bigint generated always as identity primary key,
  company_id  integer not null references public.companies(id) on delete cascade,
  fase        text not null,
  item_chave  text not null,
  status      text default 'nao',        -- nao | andamento | concluido | na
  pendencia   text default '',           -- '' | analista | prestadora
  data        date,
  anotacoes   text default '',
  updated_at  timestamptz default now(),
  unique (company_id, item_chave)
);

create table if not exists public.recurring_deliverables (
  id                bigint generated always as identity primary key,
  company_id        integer not null references public.companies(id) on delete cascade,
  tipo              text not null,
  descricao         text default '',
  data_solicitacao  date not null,
  prazo_dias        integer default 5,
  prazo_data        date,
  status            text default 'aberto',   -- aberto | finalizado
  data_finalizacao  date,
  dentro_sla        boolean,
  created_at        timestamptz default now()
);

create index if not exists idx_checklist_company on public.checklist_items(company_id);
create index if not exists idx_recurring_company on public.recurring_deliverables(company_id);

-- ---------- RLS (ferramenta interna: leitura/escrita liberadas via anon) ----------
alter table public.companies              enable row level security;
alter table public.analysts               enable row level security;
alter table public.checklist_items        enable row level security;
alter table public.recurring_deliverables enable row level security;

do $$
begin
  -- companies
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='companies' and policyname='open_all') then
    create policy open_all on public.companies for all to anon, authenticated using (true) with check (true);
  end if;
  -- analysts
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='analysts' and policyname='open_all') then
    create policy open_all on public.analysts for all to anon, authenticated using (true) with check (true);
  end if;
  -- checklist_items
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='checklist_items' and policyname='open_all') then
    create policy open_all on public.checklist_items for all to anon, authenticated using (true) with check (true);
  end if;
  -- recurring_deliverables
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='recurring_deliverables' and policyname='open_all') then
    create policy open_all on public.recurring_deliverables for all to anon, authenticated using (true) with check (true);
  end if;
end$$;

-- ---------- SEED ----------
insert into public.analysts (nome) values ('ISABELLA FARINA') on conflict (nome) do nothing;

INSERT INTO public.companies (id,cnpj,razao_social,analista_responsavel,situacao,condicao,emails,is_nova) VALUES
(2,'49.232.014/0001-20','UNI SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO LTDA','ISABELLA FARINA','ATIVO','',ARRAY['stfc@giganet.inf.br','seac@gigan','jaqueline_ds124@hotmail.com','financeiro@souuni.com']::text[],false),
(3,'10.776.806/0001-20','PLANALTO NET LTDA','ISABELLA FARINA','ATIVO','',ARRAY['eduardodecastront@hotmail.com','eduardo@planaltonet.net.br','gustavo@planaltonet.net.br','amanda@planaltonet.net.br','serconassessoria@hotmail.com','wmelo_2008@yahoo.com.br']::text[],false),
(4,'22.729.872/0001-28','NORTE.NET TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['gerencia-adm@nortenettelecom','adm-sistemas@nortenettelecom.com.br','gerencianortenet@gmail.com','gerencia-adm@central.nortenett','gerencia-adm@nortenettelecom.com.br']::text[],false),
(5,'17.225.891/0001-87','VIAVELOZ REDES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['contato@viavelozredes.com.br','galegavelasco@gmail.com','janapvelascolopes@gmail.com']::text[],false),
(6,'09.134.587/0001-04','NEWNET TELECOM LTDA','ISABELLA FARINA','ATIVO','',ARRAY['franciscoassis.57@hotmail.com','newnettelecom@hotmail.com','jassoncarneiro@yahoo.com.br','newnettelecom@gmail.com']::text[],false),
(7,'24.844.772/0001-78','RIBEIRO E ABREU PROVEDOR DE INTERNET LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@zetektelecom.com.br']::text[],false),
(8,'11.393.662/0001-95','CLICK.COM TELECOMUNICAÇÕES LTDA - ME','ISABELLA FARINA','ATIVO','',ARRAY['albyno2@hotmail.com','adm@provedorclick.com.br','click.com@hotmail.com','financeiro@provedorclick.com.br','laisesmadv@gmail.com','leo2rocha@hotmail.com','click.com@provedorclick.com.br']::text[],false),
(9,'12.983.319/0001-63','POMBONET TELECOMUNICACOES E INFORMATICA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['adm@pombonet.com.br','alansilvano@pombonet.com.br','contato@pombonet.com.br','bruno.reis@pombonet.com.br','contasapagar@pombonet.com.br','ernandes.costa@pombonet.com.br','filipe@homefibra.com.br','joao.camilo@pombonet.com.br','financeiro@pombonet.com.br','tamires.mendes@pombonet.com.br']::text[],false),
(10,'22.723.409/0001-79','SINAL DO CEU TELECOM COMERCIO E SERVICOS EIRELI','ISABELLA FARINA','ATIVO','',ARRAY['dayane@sinaldoceu.com.br','sinaldoceu@hotmail.com']::text[],false),
(11,'08.980.148/0001-41','ADAPT LINK SERVIÇOS DE COMUNICAÇÃO MULTIMÍDIA EIRELI','ISABELLA FARINA','ATIVO','',ARRAY['Claudio.jr@adaptlink.com.br','projetos@adaptlink.com.br','financeiro@adaptlink.com.br','george@adaptlink.com.br','comercial@adaptlink.com.br']::text[],false),
(12,'10.940.364/0001-05','EBER DEJANI PEREIRA DE ALBERNAZ','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@provedoruniversal.com.br','ebersvp@hotmail.com','suporte@provedoruniversal.com.br']::text[],false),
(13,'08.584.873/0001-09','CDI TELECOM LTDA - EPP','ISABELLA FARINA','ATIVO','',ARRAY['andersonadm@hotmail.com','cassio@cditelecom.com.br','financeiro_01@cditelecom.com.br']::text[],false),
(14,'15.263.327/0001-23','PRISMA TELECOMUNICACOES LTDA. - EPP','ISABELLA FARINA','ATIVO','',ARRAY['robsonpa@hotmail.com','assuncao.robson@gmail.com','josthon@prismatelcom.com.br']::text[],false),
(15,'02.862.767/0001-55','RAMOS INFORMATICA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['karine@fibercomp.com.br','dhones@fibercomp.com.br','contato@fibercomp.com.br']::text[],false),
(16,'11.001.854/0001-09','FORZA TELECOMUNICAÇÃO LTDA','ISABELLA FARINA','ATIVO','',ARRAY['almichel@terra.com.br','fagiacomini@hotmail.com','financeiro@dinamicca.com.br','cleci@vivaconecta.com.br','financeiro@vivaconecta.com.br','largogabi@hotmail.com','marcos@dinamicca.com.br','dinamiccars@yahoo.com.br','evolutionet@hotmail.com','evolutionnet.solintel@gmail.com','pricila@vivaconecta.com.br','luis@forzatelecom.com.br','marcio@vivatelecom.net.br','marcos@forzatelecom.com.br']::text[],false),
(17,'29.726.583/0001-14','LENILSON PATRIOTA DE SOUSA JUNIOR EIRELI','ISABELLA FARINA','ATIVO','',ARRAY['juniornetrh@gmail.com.br','fiscal@jrtelecom.psi.br','gnetprovedor@hotmail.com','ELETRÔNICAtiago.silva@jrtelecom.com.br']::text[],false),
(18,'31.540.563/0001-04','LPJ TELECOM E SERVIÇOS DIGITAIS LTDA','ISABELLA FARINA','ATIVO','',ARRAY['fiscal@jrtelecom.psi.br','juniornetrh@gmail.com','M ELETRÔNICAtiago.silva@jrtelecom.com.br']::text[],false),
(19,'11.092.705/0001-00','L E M TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['juniornetrh@gmail.com','fiscal@jrtelecom.psi.br','juniornetsuporte@gmail.com','tiago.silva@jrtelecom.com.br']::text[],false),
(20,'10.220.038/0001-23','ZILIONET TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['elias@redesulnet.com.br','contasapagar@sulnet.com.br','paula@sulnet.com.br','zilio@redesulnet.com.br','willian.ferreira@sulnet.com.br','Sarana.severo@sulnet.com.br']::text[],false),
(21,'10.703.677/0001-40','P4 TELECOM LTDA.','ISABELLA FARINA','ATIVO','',ARRAY['thais@p4telecom.com.br','junior@p4telecom.com.br','joice.alves@p4telecom.com.br','financeiro2@p4telecom.com.b','andre@p4telecom.com.br']::text[],false),
(22,'12.628.299/0001-02','REALTELE SERVIÇOS DIGITAIS LTDA','ISABELLA FARINA','ATIVO','',ARRAY['rodrigo@dipel.com.br','adm@dipelnet.com.br','financeiro@dipelnet.com.br','financeiro6@dipelnet.com.br','fiscal1@dipelnet.com.br','comercial1@dipelnet.com.br','FINANCEIROCAFELANDIA@DIPELNET.COM.BR','cadastro2@dipelnet.com.br']::text[],false),
(23,'14.629.705/0001-87','BRASIL DIGITAL SERVIÇOS DE INFORMÁTICA E COMÉRCIO LTDA','ISABELLA FARINA','ATIVO','',ARRAY['mirian.beleza@brasildigital.net.br','mirian.beleza.matias.123@gmail.com','tiagomatias@linuxap.com.br','mirianbelezamatias@gmail.com','diego.matias@brasildigital.net.br','gustavo@brasildigital.net','financeiro@brasildigital.net.br','walisson.gois@brasildigital.net.br','brasildigital@linuxap.com.br']::text[],false),
(24,'05.896.206/0001-65','BRASREDE TELECOMUNICACOES LTDA - EPP','ISABELLA FARINA','ATIVO','',ARRAY['vasconcelos@brasrede.com.br','financeiro@brasrede.com.br','comercial@brasrede.com.br','barth.marco@gmail.com','natanael@brasrede.com.br','kroker@pektelecom.com','alexandre.kroker@pektelecom.com','jose.ricardo@pektelecom.com','raquel@brasrede.com.br','tesouraria@brasrede.com.br']::text[],false),
(25,'26.453.505/0001-03','ZAAZ PROVEDOR DE INTERNET E TELECOMUNICACOES S.A.','ISABELLA FARINA','ATIVO','',ARRAY['a.rodrigo@zaaztelecom.com.br','financeiro@zaaztelecom.com.br','henrique.borges@zaaztelecom.com.br','thiago@zaaztelecom.com.br','luiz.mortari@zaaztelecom.com.br']::text[],false),
(26,'38.317.583/0001-51','XOX TELECOM TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['gerson@gfmacesso.com.br']::text[],true),
(27,'30.090.709/0001-96','IMPACTO INTERNET LTDA','ISABELLA FARINA','ATIVO','',ARRAY[]::text[],false),
(28,'27.924.375/0001-02','TELEFONARNET TELECOMUNICAÇÕES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['adm@voxxtelecom.com','financeiro@voxxtelecom.com','financeiro02@voxxtelecom.com.br','financeiro@telefonarnet.com.br','contato@telefonarnet.com.br']::text[],false),
(29,'35.455.760/0001-78','CONNECT RIO SERVICOS DE COMUNICACAO E MULTIMIDIA DE INTERNET EIRELI','ISABELLA FARINA','ATIVO','',ARRAY['adm@connectrio.com.br','ass.financeiro@connectrio.com.br','wellington.pontes@connectrio.com.br']::text[],false),
(30,'32.200.588/0001-13','TEK TELECOM LTDA','ISABELLA FARINA','ATIVO','',ARRAY['ricardo@tektelecom.com.br','matheus@tektelecon.com','sssantonio@bol.com.br','navarrettecamila@gmail.com','financeiro@tektelecom.com.br','alinne@tektelecom.com.br']::text[],false),
(31,'00.304.533/0001-67','JURANDIR DE ANDRADE','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@info-bras.net.br','patricia.clivati@bposolintel.com.br','jurandir@info-bras.net.br']::text[],false),
(32,'46.870.574/0001-11','VELLON SERVICOS DE COMUNICACAO MULTIMIDIA E DIGITAIS LTDA','ISABELLA FARINA','ATIVO','',ARRAY['gleisson.gomes@vellon.com.br','financeiro@vellon.com.br','contasapagar@vellon.com.br','thiago.castro@vellon.com.br']::text[],false),
(33,'04.097.715/0001-65','COMPUTEX INFORMÁTICA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['adrianacomputex@hotmail.com','orionecomputex@hotmail.com']::text[],false),
(34,'50.920.230/0001-47','NET JACAREI TELECON LTDA - EPP','ISABELLA FARINA','ATIVO','',ARRAY['comercial@netjacarei.com.br','fabio@netjacarei.com.br','fabricia@netjacarei.com.br','cristina@netjacarei.com.br','luan@netjacarei.com.br','administrativo@netjacarei.com.br']::text[],false),
(35,'28.111.835/0001-38','ZOMM NET TELECOM LTDA','ISABELLA FARINA','ATIVO','',ARRAY['zommnettelecomltda@gmail.com']::text[],false),
(36,'19.490.981/0001-20','RPNET SERVICOS DE TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@rpnettelecom.com.br']::text[],false),
(37,'08.358.956/0001-71','M.I. INTERNET LTDA.','ISABELLA FARINA','ATIVO','',ARRAY['moises@c3telecom.com.br','higor@c3telecom.com.br','eduardo@c3telecom.com.br','sperb.edu@gmail.com']::text[],false),
(38,'04.433.859/0001-45','INTERAGE TECNOLOGIA & PROVEDOR DE INTERNET LTDA','ISABELLA FARINA','ATIVO','',ARRAY['crm.contabilidade@yahoo.com','sousajc@uol.com.br','kerigmanet@hotmail.com','ferreira.reinaldo@hotmail.com']::text[],false),
(39,'02.948.795/0001-90','ACT INTERNET LTDA - ME','ISABELLA FARINA','ATIVO','',ARRAY['contabilidade@acessotelecom.digital','levilins@acessotelecom.digital','financeiro@acessotelecom.digital','marcoslins@acessotelecom.digital']::text[],false),
(40,'31.601.677/0001-09','CONEXAO MB E TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['deborasouza@conexaomb.com.br','souzasdebora@gmail.com']::text[],false),
(41,'13.367.910/0001-59','WIFI TECNOLOGIA E INFORMACAO LTDA','ISABELLA FARINA','ATIVO','',ARRAY['selestino@interlig.com','esdras.leal@interlig.com','esdrasleal13@hotmail.com','financeiro@interlig.com','estevam@interlig.com','willian.zanuzo@interlig.com','juliana.miranda@interlig.com']::text[],false),
(42,'06.218.109/0001-86','INTERLIGUE TELECOMUNICAÇÕES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['contato@lgcnet.com.br','clemersonmenezesrocha@gmail.com','contato.lgconect@gmail.com']::text[],false),
(43,'24.722.273/0001-08','L G C PROVEDOR DE INTERNET','ISABELLA FARINA','ATIVO','',ARRAY['contato@lgcnet.com.br','clemersonmenezesrocha@gmail.com','contato.lgconect@gmail.com']::text[],false),
(44,'13.421.420/0001-93','A C GOMES - ME','ISABELLA FARINA','ATIVO','',ARRAY['andrebfmro@gmail.com','alexandracarlaama@gmail.com','priscilazecnet@gmail.com']::text[],false),
(45,'37.427.969/0001-53','ULISSES DE OLIVEIRA SANTOS','ISABELLA FARINA','ATIVO','',ARRAY['ulissesghao@gmail.com','Clemilsonbraga@gmail.com']::text[],false),
(46,'05.072.224/0001-22','BERTASSO & CIA LTDA - ME','ISABELLA FARINA','ATIVO','',ARRAY['vsp4marcos@hotmail.com','vsp4marcos@bertasso.com.br','ti@bertasso.com.br','olimpia@nitrointernet.com.br','financeiro@bertasso.com.br']::text[],false),
(47,'07.353.979/0001-20','VALDEMAR MELO DA MOTA & CIA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['juridico@conecttelecom.com.br','maycon@conecttelecom.com.br','gerencia@contareisp.com.br','contabilidade@contareisp.com.br','dfiscal@contareisp.com.br','administracao@conecttelecom.com.br']::text[],false),
(48,'19.511.493/0001-52','URUPESNET PROVEDOR DE INTERNET LTDA','ISABELLA FARINA','ATIVO','',ARRAY['rodrigo@urupesnet.com.br','financeiro@urupesnet.com.br','dailsonledesma@hotmail.com']::text[],false),
(49,'00.938.920/0001-55','INFORMATICA ITAPIRANGA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@nedel.inf.br','henriquenedel@gmail.com','joni@nedel.com.br','net@nedel.inf.br','vicente@nedel.inf.br','vicente@inateccontabilidade.com.br']::text[],false),
(50,'21.476.236/0001-79','NAVE NET SERVICOS DE INTERNET LTDA','ISABELLA FARINA','ATIVO','',ARRAY['adelmo30@hotmail.com','financeiro@navenet.com.br','comercial.fibra@navenet.com.br','marcos.rogerio@navenet.com.br']::text[],false),
(51,'10.934.244/0001-03','AMA SERVICOS MULTIMIDIA LTDA - ME','ISABELLA FARINA','ATIVO','',ARRAY['contasapagar@amatelecom.com.br','carlosjr@amatelecom.com.br','leticia@amatelecom.com.br','cunhaunilink@hotmail.com','carlos.jr.flp@hotmail.com','contabilidade@amatelecom.com.br']::text[],false),
(52,'05.690.288/0001-97','AONET SERVIÇOS DE COMUNICAÇÃO LTDA','ISABELLA FARINA','ATIVO','',ARRAY['alonso-andre@hotmail.com','andressa.pinheiro@aonet.com.br']::text[],false),
(53,'37.969.283/0001-94','REDE VIRTUAL TELECOM LTDA','ISABELLA FARINA','ATIVO','',ARRAY['farukredevisual@gmail.com','redevirtual.fiscontabil@gmail.com','ynosnosredna@hotmail.com']::text[],false),
(54,'01.057.537/0001-50','E. W. DE AGUIAR LIMA COMERCIO - EPP','ISABELLA FARINA','ATIVO','',ARRAY['adalbertoffarras@gmail.com','eliasvisualprovedor@gmail.com','redevisualnet@hotmail.com','financeiro@redevisualnet.com.br','isaac@redevisualnet.com.br']::text[],false),
(55,'09.233.246/0001-88','R. ALECIO SACHETTI & CIA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['rafael@sattinternet.com.br','gerencia@sattinternet.com.br']::text[],false),
(56,'10.534.258/0001-21','MULTIPLA SERVICOS INTELIGENTES LTDA - EPP','ISABELLA FARINA','ATIVO','',ARRAY['andrea@tapi.com.br','dion@multipla.tv.br','ericoengenheiroconsultor@gmail.com','financeiro@multipla.tv.br','mari@multipla.tv.br','leonardo@multipla.tv.br','filipe@multipla.tv.br','atendimento05@tapi.com.br']::text[],false),
(57,'09.259.381/0001-00','AMIGA NET COMERCIO DE EQUIPAMENTOS E SERVICOS LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro01@amiganet.com.br','paulo@amiganet.com.br','rodrigo@ecmazocato.com.br','sercareli@gmail.com']::text[],false),
(58,'11.089.980/0001-67','ALTANET SERVICOS DE TELECOMUNICACOES EIRELI','ISABELLA FARINA','ATIVO','',ARRAY['thomaz.silva@interlig.com','juliana.miranda@interlig.com','financeiro@interlig.com','estevam@interlig.com','willian.zanuzo@interlig.com','selestino@interlig.com','esdras.leal@interlig.com','esdrasleal13@hotmail.com']::text[],false),
(59,'16.911.389/0001-67','CLICKNET TELECOMUNICACOES PROVEDOR DE INTERNET LTDA','ISABELLA FARINA','ATIVO','',ARRAY['noc@cipel.com.br','diana.moreira@clicknet.com.br','marcia.vieira@clicknet.net.br','financeiro@clicknet.net.br','anderson.paulino@clicknet.net.br','deivis@clicknet.com.br','fernando@sitel.com.br','contato@clicknet.net.br']::text[],false),
(60,'24.412.573/0001-90','MARLENE FRISKE SAUERESSIG EIRELI','ISABELLA FARINA','ATIVO','',ARRAY['adrianols1976@hotmail.com','pwtelecomipiranga@gmail.com','marlenesaueressig@yahoo.com.br']::text[],false),
(61,'18.456.569/0001-21','WORLDNET SERVICOS DE TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro03@nbstelecom.com.br','financeiro@nbstelecom.com.br','noc@worldnetfibra.com.br','finananceiro@nbstelecom.com.br','ceo@nbstelecom.com.br','financeiro@souuni.com']::text[],false),
(62,'12.161.988/0001-50','TOP TELECOM SERVICOS E TECNOLOGIA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@toptelecom.psi.br']::text[],false),
(63,'07.246.923/0001-77','GEE TECNOLOGIA DA INFORMAÇÃO & TELECOM LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@geeinformatica.com.br','Gee@geetecnologia.com.br']::text[],false),
(64,'10.387.977/0001-67','EAGLE REDES DE TELECOMUNICACOES LTDA - ME','ISABELLA FARINA','ATIVO','',ARRAY['klc.assessoriacontabil@gmail.com','luiscarlos232@terra.com.br','luiscarlos_camargo@hotmail.com','erikelima@hotmail.com','krybeen@gmail.com','erike@eagleredes.com.br','contabilidade@redeconecta.com']::text[],false),
(65,'21.801.834/0001-76','SGPIEDADENET-PROVEDOR DE INTERNET LTDA','ISABELLA FARINA','ATIVO','',ARRAY['sgpiedadenet@hotmail.com']::text[],false),
(66,'07.395.462/0001-02','DIGINET INFORMATICA BAHIA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['welitonemanuel@gmail.com','lumacontabilidade@hotmail.com','diginet0800@hotmail.com','jorlandoefarias@hotmail.com']::text[],false),
(67,'10.299.775/0001-63','PROVEDOR SANTA BARBARA LTDA','ISABELLA FARINA','ATIVO','',ARRAY['lsj_tecnologia@hotmail.com','netprov@live.com']::text[],false),
(68,'19.502.334/0001-91','METROFIBER TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','Enviado',ARRAY[]::text[],false),
(69,'315.010.100-00','FOX LINK TELECOMUNICACOES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['financeiro@foxlink.com.br','ricardojaren@foxlink.com.br']::text[],false),
(70,'12.464.859/0001-30','SGV SERVICOS DE TI E TELECOM LTDA','ISABELLA FARINA','ATIVO','',ARRAY['carolinecastrosgv@gmail.com','cuiaba.sergio@gmail.com','admsgvtelecom@gmail.com','comercial@sgvtelecom.com.br']::text[],false),
(71,'30.090.709/0001-96','INTERFIBRAS TELECOMUNICAÇÕES LTDA','ISABELLA FARINA','ATIVO','',ARRAY['administrativo@interfibras.com.br','edmundog900@gmail.com']::text[],true)
ON CONFLICT (id) DO NOTHING;
