#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

URL=$(jq -r .SUPABASE_URL "$DIR/env.json")
KEY=$(jq -r .SUPABASE_KEY "$DIR/env.json")
EMAIL="test+$(date +%s)@example.com"
PASS="Test1234!"

echo "1/4 — Lecture anonyme de /movies (doit renvoyer 200 et un tableau)"
curl -s -w '   HTTP %{http_code}\n' "$URL/rest/v1/movies?select=id,title&limit=2" \
  -H "apikey: $KEY"

echo "2/4 — Lecture anonyme de /favorites (RLS : doit renvoyer [] et non une erreur)"
curl -s -w '   HTTP %{http_code}\n' "$URL/rest/v1/favorites?select=id" \
  -H "apikey: $KEY"

echo "3/4 — Inscription ($EMAIL)"
SIGNUP=$(curl -s "$URL/auth/v1/signup" -H "apikey: $KEY" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}")
echo "   $(echo "$SIGNUP" | head -c 200)"

echo "4/4 — Connexion + lecture authentifiée de /profiles"
TOKEN=$(curl -s "$URL/auth/v1/token?grant_type=password" -H "apikey: $KEY" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" | jq -r .access_token)

if [[ "$TOKEN" == "null" || -z "$TOKEN" ]]; then
  echo "   ✗ Pas de token. Cause probable : « Confirm email » est activé."
  echo "     Désactivez-le dans Authentication > Providers > Email."
  exit 1
fi

curl -s -w '   HTTP %{http_code}\n' "$URL/rest/v1/profiles?select=*" \
  -H "apikey: $KEY" -H "Authorization: Bearer $TOKEN"
echo "   ↑ doit contenir exactement 1 ligne : le trigger handle_new_user a bien tourné."
