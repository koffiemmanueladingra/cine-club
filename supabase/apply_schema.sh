#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${SUPABASE_DB_URL:-}" ]]; then
  echo "Erreur : SUPABASE_DB_URL n'est pas défini." >&2
  echo "Lancez d'abord : source supabase/db.env" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "→ Application de schema.sql"
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f "$DIR/schema.sql"

echo "→ Application de seed.sql"
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f "$DIR/seed.sql"

echo "✓ Schéma et données de démonstration appliqués."
