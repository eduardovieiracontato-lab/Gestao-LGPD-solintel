// ============================================================
//  Configuração pública do Supabase (chave ANON — segura com RLS ativo)
//  Este arquivo é lido pelo index.html no navegador.
//  Na Netlify, ele pode ser REGERADO automaticamente no build a partir
//  das variáveis de ambiente SUPABASE_URL e SUPABASE_ANON_KEY (ver netlify.toml).
// ============================================================
window.SUPABASE_URL = "https://fzegpwebfdzbtjgnhndq.supabase.co";
window.SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ6ZWdwd2ViZmR6YnRqZ25obmRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4MDc2ODMsImV4cCI6MjA5ODM4MzY4M30.lLBVQzazZ7hO3FEFO2f5xghPvhLSbNdQTuoU-xqUCoY";

// ------------------------------------------------------------
//  Integração com a PLANILHA (Google Sheets) — opcional, mas necessária
//  para que alterações na planilha reflitam automaticamente no site.
//  Cole aqui a URL do CSV PUBLICADO NA WEB da sua planilha
//  (Arquivo > Compartilhar > Publicar na Web > aba > formato .csv).
//  Enquanto estiver como "COLE_...", o site usa apenas o Supabase.
//  Colunas esperadas: CNPJ, RAZÃO SOCIAL, ANALISTA, QNTD, SITUAÇÃO, CONDIÇÃO, E-MAILS.
// ------------------------------------------------------------
window.SHEET_CSV_URL = "https://docs.google.com/spreadsheets/d/10MGviw0dECWiRpedGvXZTsf_1Ne2mDoGa9vo0FmWtF0/gviz/tq?tqx=out:csv";
