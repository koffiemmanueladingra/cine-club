# Contrat d'API

Base : `https://<projet>.supabase.co`
En-tête obligatoire sur **toutes** les requêtes : `apikey: <SUPABASE_KEY>`.

---

## 1. Authentification — GoTrue (`/auth/v1`)

### POST `/signup`

```json
{ "email": "ada@example.com", "password": "secret123",
  "data": { "display_name": "Ada" } }
```

`data` alimente `raw_user_meta_data` côté PostgreSQL ; le trigger
`handle_new_user` y lit `display_name` pour créer la ligne `profiles`.

Réponse (confirmation d'e-mail désactivée) : identique à `/token` ci-dessous.
Réponse (confirmation activée) : objet utilisateur **sans** `access_token` —
`SessionDto.fromJson` lève alors une `FormatException`, interprétée comme
« compte créé, session non ouverte ».

### POST `/token?grant_type=password`

```json
{ "email": "ada@example.com", "password": "secret123" }
```

```json
{
  "access_token": "eyJ...",
  "token_type": "bearer",
  "expires_in": 3600,
  "expires_at": 1767225600,
  "refresh_token": "v1.M2Rk...",
  "user": { "id": "uuid", "email": "ada@example.com",
            "user_metadata": { "display_name": "Ada" } }
}
```

`expires_at` (epoch secondes) est prioritaire sur `expires_in` pour calculer
l'expiration ; à défaut, 3600 s est utilisé.

### POST `/token?grant_type=refresh_token`

```json
{ "refresh_token": "v1.M2Rk..." }
```

M�me forme de réponse. Un échec (400/401) signifie que le refresh token est
révoqué ou expiré : l'intercepteur purge alors la session.

### POST `/logout`

En-tête `Authorization: Bearer <access_token>`. Réponse `204`.

### Erreurs GoTrue

| Code | Corps typique | Traduction applicative |
|---|---|---|
| 400 | `{"error":"invalid_grant","error_description":"..."}` | `AuthFailure` |
| 400 | `{"code":400,"error_code":"invalid_credentials","msg":"..."}` | `AuthFailure` — message remplacé par « E-mail ou mot de passe incorrect. » |
| 422 | `{"msg":"Password should be at least 6 characters"}` | `AuthFailure` avec le message serveur |
| 429 | limite de débit | `ServerFailure` |

---

## 2. Données — PostgREST (`/rest/v1`)

En-têtes : `apikey` + `Authorization: Bearer <access_token>`.

### GET `/movies?select=*&order=release_year.desc`

```json
[{ "id": "uuid", "title": "Metropolis",
   "overview": "…", "poster_url": "https://…",
   "release_year": 1927, "rating": 8.3,
   "genre": "Science-fiction", "created_at": "2026-01-01T00:00:00Z" }]
```

### GET `/movies?select=*&id=eq.<uuid>&limit=1`

Renvoie un tableau de 0 ou 1 élément.

### GET `/favorites?select=id,created_at,movie:movies(*)&order=created_at.desc`

`movie:movies(*)` est une **jointure d'embarquement** PostgREST : la ligne
`favorites` embarque son film sous la clé `movie`.

```json
[{ "id": "uuid", "created_at": "2026-02-01T12:00:00Z",
   "movie": { "id": "uuid", "title": "Nosferatu", "…": "…" } }]
```

Aucun filtre `user_id` n'est envoyé : la politique RLS
`auth.uid() = user_id` filtre déjà côté serveur.

### POST `/favorites`

```json
{ "movie_id": "uuid" }
```

`user_id` **n'est pas envoyé** : la colonne a pour valeur par défaut
`auth.uid()`. En-tête `Prefer: return=minimal`.

| Code | Signification | Traitement |
|---|---|---|
| 201 | créé | succès |
| 409 | doublon (`favorites_unique_pair`) | traité comme un succès (idempotence) |
| 403 | violation RLS | `AuthFailure` |

### DELETE `/favorites?movie_id=eq.<uuid>`

RLS restreint la suppression aux lignes de l'utilisateur : aucun filtre
`user_id` n'est nécessaire.

### GET `/profiles?select=*&id=eq.<uuid>&limit=1`

### PATCH `/profiles?id=eq.<uuid>`

```json
{ "display_name": "Ada L.", "updated_at": "2026-02-01T12:00:00Z" }
```

En-tête `Prefer: return=representation` pour récupérer la ligne mise à jour
sans second GET.

### Erreurs PostgREST

```json
{ "code": "42501", "message": "…", "details": null, "hint": null }
```

| Code HTTP | Cause fréquente |
|---|---|
| 401 | token absent, expiré ou `apikey` manquant |
| 403 | politique RLS refusant l'opération |
| 404 | table absente du cache de schéma (`notify pgrst, 'reload schema'`) |
| 409 | violation de contrainte d'unicité |

Référence : <https://postgrest.org/en/stable/references/errors.html>
