# Configuration du backend Supabase

> ## ⚡ Ce projet est déjà configuré
>
> Les sections 1, 2 et 6 sont **déjà faites** : le projet Supabase existe et
> `env.json` est rempli à la racine du dépôt.
>
> | Élément | Valeur | Fichier |
> |---|---|---|
> | Project URL | `https://qkzpjimpmehmfqzgzuqy.supabase.co` | `env.json` |
> | Project ref | `qkzpjimpmehmfqzgzuqy` | — |
> | Clé publiable | `sb_publishable_RsPTDVA7...` | `env.json` |
> | Chaîne PostgreSQL | `postgresql://postgres:***@db.qkzpjimpmehmfqzgzuqy.supabase.co:5432/postgres` | `supabase/db.env` |
>
> `env.json` et `supabase/db.env` sont **ignorés par Git** (voir
> `.gitignore`). Ils ne partiront donc pas sur GitHub ; toute personne
> clonant le dépôt devra les recréer depuis `env.example.json` et
> `supabase/db.env.example`.
>
> **Il reste à faire** : les sections 3, 4, 5 et 7 — créer le schéma,
> charger les données, régler l'authentification, vérifier. Raccourci :
>
> ```bash
> source supabase/db.env && ./supabase/apply_schema.sh   # sections 3 + 4
> ./supabase/smoke_test.sh                               # section 7
> ```

Ce document décrit **toutes** les opérations à effectuer côté Supabase pour
que l'application fonctionne. Durée : environ 10 minutes.

---

## 1. Créer le projet

1. Se connecter sur <https://supabase.com/dashboard>.
2. **New project** → nom `cine-club`, mot de passe de base de données (à
   conserver), région la plus proche des utilisateurs.
3. Attendre la fin du provisionnement (~2 min).

---

## 2. Récupérer l'URL et la clé publique

**Project Settings → API Keys**, puis **Connect** en haut du dashboard.

Deux valeurs sont nécessaires :

| Variable | Où la trouver | Exemple |
|---|---|---|
| `SUPABASE_URL` | Project URL | `https://abcdefghijkl.supabase.co` |
| `SUPABASE_KEY` | Publishable key | `sb_publishable_...` |

### Quelle clé utiliser ?

Supabase a introduit en 2025 des clés opaques `sb_publishable_...` /
`sb_secret_...` qui remplacent les anciennes clés JWT `anon` /
`service_role`, **dépréciées à échéance fin 2026**. Les projets créés
récemment ne proposent plus les clés héritées.

- Utiliser la **clé publiable** (`sb_publishable_...`) dans l'application.
  Si votre projet est ancien et ne propose que `anon`, celle-ci fonctionne à
  l'identique.
- **Ne jamais** embarquer une clé `sb_secret_...` (ou `service_role`) dans un
  client mobile : elle contourne les politiques RLS.

La clé publiable est publique par conception. La sécurité repose entièrement
sur le **Row Level Security** défini à l'étape 3.

Références :
- <https://supabase.com/docs/guides/getting-started/api-keys>
- <https://supabase.com/docs/guides/getting-started/migrating-to-new-api-keys>

---

## 3. Créer le schéma

> **Voie rapide (scriptée)** — nécessite `psql` :
> ```bash
> source supabase/db.env
> ./supabase/apply_schema.sh
> ```
> Le script applique `schema.sql` puis `seed.sql` avec `ON_ERROR_STOP=1`,
> ce qui évite un schéma à moitié créé en cas d'erreur. Il couvre aussi la
> section 4. Sinon, suivre la procédure manuelle ci-dessous.
>
> Note : le port `5432` de `db.<ref>.supabase.co` est la connexion *directe*.
> Si votre réseau est en IPv4 uniquement, elle peut échouer ; utilisez alors
> la chaîne « Session pooler » fournie dans **Project Settings → Database →
> Connection string**, ou passez par le SQL Editor.

**SQL Editor → New query** → coller le contenu de
[`supabase/schema.sql`](../supabase/schema.sql) → **Run**.

Ce script crée :

| Objet | Rôle |
|---|---|
| `public.movies` | catalogue, lecture seule pour les clients |
| `public.profiles` | profil applicatif lié à `auth.users` |
| `public.favorites` | relation utilisateur ↔ film |
| `handle_new_user()` + trigger | crée automatiquement le profil à l'inscription |
| Politiques RLS | isolation stricte des données par utilisateur |

### Points de sécurité importants

1. **RLS activé sur les trois tables.** Sans cela, la clé publiable donnerait
   un accès complet en lecture/écriture à toute personne extrayant la clé de
   l'APK.
2. **`favorites.user_id` a pour valeur par défaut `auth.uid()`.** Le client
   n'envoie que `movie_id` ; il ne peut donc pas écrire dans les favoris d'un
   autre utilisateur, même en forgeant la requête.
3. **`movies` n'a aucune politique d'écriture.** Le catalogue n'est
   modifiable que via le SQL Editor ou une clé secrète côté serveur.
4. Les politiques utilisent `(select auth.uid())` plutôt que `auth.uid()` :
   PostgreSQL évalue alors la fonction une seule fois par requête au lieu
   d'une fois par ligne. C'est la forme recommandée par Supabase pour les
   performances.

---

## 4. Charger les données de démonstration

**SQL Editor → New query** → coller [`supabase/seed.sql`](../supabase/seed.sql)
→ **Run**. Huit films sont insérés. Le script est rejouable sans créer de
doublons (`on conflict (title) do nothing`).

---

## 5. Régler l'authentification

**Authentication → Sign In / Providers → Email**

| Réglage | Valeur recommandée en développement | Pourquoi |
|---|---|---|
| Enable email provider | activé | — |
| Confirm email | **désactivé** | sinon aucune session n'est ouverte à l'inscription et il faut relever la boîte mail à chaque test |
| Minimum password length | 6 (défaut) | doit rester cohérent avec `_minPasswordLength` dans `register_screen.dart` |

> L'application gère **les deux cas**. Si « Confirm email » reste activé,
> `AuthRepository.register` renvoie `sessionOpened = false` et l'écran de
> connexion affiche « Compte créé. Confirmez votre adresse e-mail ».

**Authentication → Sessions** (facultatif) : la durée de vie de l'access token
est de 3600 s par défaut. La réduire à 60 s est la façon la plus simple de
**tester le refresh token** en conditions réelles.

---

## 6. Configurer l'application Flutter

```bash
cp env.example.json env.json
```

```json
{
  "SUPABASE_URL": "https://abcdefghijkl.supabase.co",
  "SUPABASE_KEY": "sb_publishable_xxxxxxxxxxxxxxxx"
}
```

```bash
flutter run --dart-define-from-file=env.json
```

`env.json` est listé dans `.gitignore`. Les valeurs sont injectées **à la
compilation** via `String.fromEnvironment` : elles ne transitent par aucun
fichier d'assets, contrairement à `flutter_dotenv`.

Pour un build de production :

```bash
flutter build apk --release --dart-define-from-file=env.production.json
```

---

## 7. Vérifier l'installation

### 7.1 Sans l'application (curl)

```bash
URL="https://abcdefghijkl.supabase.co"
KEY="sb_publishable_xxxxxxxxxxxxxxxx"

# a) Inscription
curl -s -X POST "$URL/auth/v1/signup" \
  -H "apikey: $KEY" -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"secret123",
       "data":{"display_name":"Testeur"}}'

# b) Connexion -> récupérer access_token
curl -s -X POST "$URL/auth/v1/token?grant_type=password" \
  -H "apikey: $KEY" -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"secret123"}'

TOKEN="<access_token renvoyé ci-dessus>"

# c) Catalogue (doit renvoyer 8 films)
curl -s "$URL/rest/v1/movies?select=*&order=release_year.desc" \
  -H "apikey: $KEY" -H "Authorization: Bearer $TOKEN"

# d) Favoris (doit renvoyer [] et non une erreur)
curl -s "$URL/rest/v1/favorites?select=id,movie:movies(*)" \
  -H "apikey: $KEY" -H "Authorization: Bearer $TOKEN"
```

### 7.2 Contrôles RLS attendus

| Test | Résultat attendu |
|---|---|
| GET `/rest/v1/movies` sans `Authorization` | `[]` ou 401 — jamais la liste complète |
| POST `/rest/v1/favorites` avec `user_id` d'un autre utilisateur | 403 (violation de politique) |
| GET `/rest/v1/profiles` connecté | uniquement votre propre ligne |

Si `movies` renvoie la liste sans token, la politique RLS n'est pas appliquée :
revérifier que `alter table ... enable row level security` a bien été exécuté.

---

## 8. Alternative sans Supabase

Le projet n'est couplé à Supabase qu'à travers quatre fichiers :

```
lib/core/config/app_config.dart                          (URLs)
lib/features/auth/data/datasources/auth_remote_data_source.dart
lib/features/*/data/datasources/*_remote_data_source.dart
```

Tout backend exposant du JWT + REST (Laravel Sanctum/Passport, NestJS,
Django REST, PocketBase…) peut les remplacer sans toucher au domaine, aux
repositories, au cache ni à l'UI. Voir
[`ADR-001`](decisions/ADR-001-backend-supabase.md).
