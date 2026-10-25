# Painel de Gestão LGPD — Solintel · Self-host (Supabase + Netlify)

Aplicação web estática (HTML/CSS/JS puro) que persiste **todo o progresso no Supabase**
(compartilhado por toda a equipe) e é hospedada na **Netlify**. Não depende mais do Lovable.

## O que já está pronto
- **Supabase criado** — projeto **"Jornada LGPD"** (`ref: fzegpwebfdzbtjgnhndq`), na sua organização.
- **Schema aplicado** (`schema.sql`): tabelas `companies`, `analysts`, `checklist_items`,
  `recurring_deliverables`, com RLS liberada para a aplicação (ferramenta interna).
- **Seed** das **70 empresas** (XOX e INTERFIBRAS marcadas como *Empresa Nova*; METROFIBER com condição *Enviado*).
- **Chaves** já colocadas em `.env` e em `env-config.js`.

## Arquivos do pacote
| Arquivo | Função |
|---|---|
| `index.html` | A aplicação completa (5 abas + painel de empresas + entregas recorrentes + dashboard). |
| `env-config.js` | Injeta `SUPABASE_URL` e `SUPABASE_ANON_KEY` no navegador (chave anon é pública, protegida pela RLS). |
| `.env` | Mesmas chaves, para o build da Netlify (e referência). |
| `.env.example` | Modelo caso você use outro projeto Supabase. |
| `schema.sql` | Estrutura + seed do banco (para recriar em qualquer Supabase). |
| `netlify.toml` + `build.sh` | Regeneram o `env-config.js` a partir das variáveis de ambiente no deploy. |

---

## PASSO A PASSO — o que VOCÊ precisa operacionalizar

### A) Supabase (já feito — só confira / ou recrie do zero)
Se for usar o projeto **"Jornada LGPD"** que já preparei, **pule para a parte B**. Para criar do zero:
1. Acesse https://supabase.com → **New project** (nome livre, defina a senha do banco, região mais próxima).
2. Abra **SQL Editor** → **New query** → cole todo o conteúdo de **`schema.sql`** → **Run**. (Cria tabelas, RLS e as 70 empresas.)
3. Vá em **Project Settings → API** (ou **Data API / API Keys**) e copie:
   - **Project URL** (ex.: `https://SUA_REF.supabase.co`)
   - **anon public key** (a chave `anon`, começa com `eyJ...`).
4. Cole esses dois valores em **`.env`** e em **`env-config.js`** (substituindo os atuais).

> ⚠️ Use **apenas a chave anon** (nunca a `service_role`). A anon é pública por natureza e o acesso é controlado pela RLS.

### B) Testar localmente (opcional, 1 min)
Como o navegador bloqueia `fetch` em `file://`, sirva a pasta por HTTP:
```
cd solintel-lgpd-app
python3 -m http.server 5173
```
Abra http://localhost:5173 → aba **Gestão de Empresas**. A faixa deve indicar “Conectado ao Supabase · 70 empresas”. Marque um item de checklist e recarregue: o dado permanece (veio do banco).

### C) Publicar na Netlify

**Opção 1 — Deploy manual (mais rápido):**
1. Entre em https://app.netlify.com → **Add new site → Deploy manually**.
2. Arraste a **pasta `solintel-lgpd-app`** inteira para a área de upload.
3. Pronto: a Netlify publica e te dá uma URL `https://SEU-SITE.netlify.app`.
   (Nesse modo ela usa o `env-config.js` já preenchido — funciona de imediato.)

**Opção 2 — Deploy via Git (recomendado para manutenção):**
1. Suba a pasta para um repositório GitHub/GitLab.
2. Netlify → **Add new site → Import from Git** → selecione o repositório.
3. Build settings: **Build command** `sh build.sh` · **Publish directory** `.` (já vêm no `netlify.toml`).
4. **Site settings → Environment variables** → adicione:
   - `SUPABASE_URL` = `https://fzegpwebfdzbtjgnhndq.supabase.co`
   - `SUPABASE_ANON_KEY` = *(a chave anon do `.env`)*
5. **Deploy**. O `build.sh` regenera o `env-config.js` a partir dessas variáveis
   (assim você pode rotacionar a chave sem editar arquivos).

### D) Vínculo com a PLANILHA (Google Sheets) — JÁ CONFIGURADO ✅
O site já está ligado à sua planilha:
`https://docs.google.com/spreadsheets/d/10MGviw0dECWiRpedGvXZTsf_1Ne2mDoGa9vo0FmWtF0`
A URL de leitura (CSV via endpoint `gviz`) já está em `env-config.js` (`window.SHEET_CSV_URL`) e no `.env`.

**Como funciona:** a cada abertura do site — e ao clicar em **⤓ Sincronizar planilha** — o app lê a planilha e atualiza as empresas no Supabase automaticamente. Assim, **toda alteração feita na planilha** (nova empresa, troca de analista, e-mails, situação, condição) reflete no site.

**Único requisito de compartilhamento:** a planilha precisa estar como **"Qualquer pessoa com o link → Leitor"** (Compartilhar → Acesso geral). Você já compartilhou por link, então deve funcionar. Se algum dia a leitura falhar, use o plano B: **Arquivo → Compartilhar → Publicar na Web → CSV**, copie o link (`.../pub?output=csv`) e substitua o valor de `window.SHEET_CSV_URL`.

**Regras da sincronização:**
- A coluna **QNTD** é o identificador da empresa (id). Nova empresa → use um QNTD único e sequencial (72, 73, ...).
- A sincronização atualiza só os **dados cadastrais** (razão social, analista, situação, condição, e-mails) e **preserva** o progresso do checklist, o DPO e as entregas recorrentes já registrados no banco.
- No deploy via Git, cadastre também `SHEET_CSV_URL` nas variáveis de ambiente da Netlify.

> A empresa **LPRINT TELECOMUNICACAO E ENGENHARIA LTDA** (id 72, CNPJ 28.216.331/0001-82) já está no banco e aparece no site. Os CNPJs de FOX LINK e INTERFIBRAS também foram corrigidos conforme a planilha.

### E) Domínio próprio (opcional)
Netlify → **Domain settings → Add a custom domain** (ex.: `lgpd.solintel.com.br`) e siga as instruções de DNS.

---

## 🔒 Acesso restrito (login) — JÁ ATIVADO
O sistema agora exige **login** e o banco só responde a **usuários autenticados**:
- Acesso permitido apenas a e-mails **@solintel.com.br** (+ exceção do admin `eduardovieiracontato@gmail.com`), imposto por gatilho no banco — não dá para burlar pelo navegador.
- As políticas do banco foram trancadas: o acesso público (`anon`) foi **removido**; só sessão logada lê/grava.

**Passos que você precisa fazer (uma vez):**
1. **Redeploy na Netlify** com esta pasta atualizada (o site agora tem tela de login). Enquanto não republicar, a versão antiga fica sem dados (o que é o esperado — fechou o acesso público).
2. No **Supabase → Authentication → URL Configuration**: em **Site URL**, cole a URL do seu site Netlify (ex.: `https://SEU-SITE.netlify.app`). Isso faz o link de confirmação de e-mail voltar para o site certo.
3. **Primeiro acesso:** abra o site → **"Criar conta"** → use `eduardo.vieira@solintel.com.br` (ou seu e-mail) e uma senha. Confirme pelo e-mail que chegar e faça login.
   - Se preferir sem a etapa de confirmação por e-mail: **Authentication → Providers → Email → desligar "Confirm email"** (mais cômodo, um pouco menos seguro).
4. Para dar acesso a mais alguém da equipe: basta a pessoa criar a conta com o e-mail **@solintel.com.br** (o gatilho barra qualquer outro domínio). Para **revogar**, remova o usuário em **Authentication → Users**.

> Camada extra opcional: no plano Netlify Pro dá para pôr também uma senha no site (Site settings → Access control → Password protection). É um reforço, mas o essencial (login por pessoa + banco trancado) já está feito.

> ⚠️ **Atenção — outras tabelas abertas neste banco:** existem tabelas `jornada_*` (provavelmente do app do Lovable) com acesso público neste mesmo projeto Supabase. Se elas não forem mais usadas, convém trancá-las também (mesmo modelo `authenticated`). Me avise que eu ajusto.

## Segurança (importante)
- A aplicação é uma **ferramenta interna** e usa a chave **anon** com **RLS liberada** (qualquer pessoa com o link lê/grava).
- Se quiser restringir o acesso, as opções são: (1) proteger o site com senha (Netlify **Password protection**, plano pago),
  ou (2) ativar **Supabase Auth** e trocar as políticas RLS `open_all` por regras baseadas em usuário logado. Posso implementar isso se desejar.
- **Nunca** exponha a chave `service_role` no front-end.

## Como o app usa o banco
- `companies` — 1 linha por ISP (analista, condição, DPO nome/contato, is_nova, e-mails).
- `checklist_items` — 1 linha por item marcado (upsert por `company_id + item_chave`): status, pendência (analista/prestadora), data, anotações.
- `recurring_deliverables` — 1 linha por entrega recorrente criada (tipo, descrição, data, prazo SLA em dias úteis, finalização e dentro/fora do SLA).
- `analysts` — lista de analistas responsáveis (para o dropdown e o botão “+ Analista”).
