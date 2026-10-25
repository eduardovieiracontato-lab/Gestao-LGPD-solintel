#!/usr/bin/env sh
# Gera env-config.js a partir das variáveis de ambiente (se definidas na Netlify).
# Caso contrário, mantém o env-config.js versionado.
if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_ANON_KEY" ]; then
  {
    printf 'window.SUPABASE_URL=%s;\n' "\"$SUPABASE_URL\""
    printf 'window.SUPABASE_ANON_KEY=%s;\n' "\"$SUPABASE_ANON_KEY\""
    printf 'window.SHEET_CSV_URL=%s;\n' "\"${SHEET_CSV_URL:-COLE_A_URL_DO_CSV_PUBLICADO_AQUI}\""
  } > env-config.js
  echo "env-config.js gerado a partir das variaveis de ambiente."
else
  echo "Variaveis de ambiente ausentes — usando env-config.js versionado."
fi
