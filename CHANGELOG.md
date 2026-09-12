# Changelog

## [0.1.3] - 2026-09-11

### Corrigé
- `error_mapper.dart` : `DioExceptionType.transformTimeout` manquant dans le
  `switch` exhaustif — seule erreur de compilation du projet.
- `exceptions.dart` : `UnauthorizedException` en paramètres `super.` avec
  `super.statusCode = 401` (lint `use_super_parameters`).
- `movie_dto.dart` : `final` sur les variables de motif (`prefer_final_locals`).

### Vérifié
- `flutter analyze` : `No issues found`.
- `flutter test` : 31 tests, aucun échec.
- Aucune ligne de `FEATURES_MATRIX.md` ne passe à `Done` : les vérifications
  de cette matrice sont comportementales et exigent une instance Supabase.


## [0.1.2] - 2026-09-11

### Modifié
- Code Dart (`lib/`, `test/`) dépouillé de ses commentaires : 158 blocs sur
  177 retirés, 19 conservés (11 %). Les blocs gardés sont ceux qui expliquent
  un choix qu'aucune relecture du code ne permet de retrouver : sérialisation
  des refresh par `QueuedInterceptor`, règles R1–R5 du mode hors-ligne,
  en-tête `apikey` exigé par PostgREST, en-tête `Prefer: return=representation`,
  401 jamais masqué par le cache.
- Directives `library;` retirées dans les fichiers dont le commentaire
  d'en-tête a disparu (elles n'existaient que pour le porter).

### Note
- Cette suppression s'écarte des règles de `projet-ia.md` (documentation
  obligatoire par fichier et par fonction). La version intégralement
  commentée reste disponible dans `cine_club_documente.zip`.


## [0.1.1] - 2026-09-11

### Ajouté
- `env.json` renseigné avec le projet Supabase `qkzpjimpmehmfqzgzuqy`
  (URL + clé publiable). Fichier non versionné.
- `supabase/db.env` : chaîne de connexion PostgreSQL pour les scripts
  d'administration. Fichier non versionné, séparé de la configuration de
  l'application — le client Flutter n'y accède jamais.
- `supabase/db.env.example` : gabarit versionné du précédent.
- `supabase/apply_schema.sh` : application de `schema.sql` puis `seed.sql`
  via psql, mot de passe lu depuis l'environnement (`ON_ERROR_STOP=1`).
- `supabase/smoke_test.sh` : vérification du backend en 4 appels curl
  (lecture publique, RLS anonyme, inscription, lecture authentifiée).

### Modifié
- `.gitignore` : ajout de `supabase/db.env`, exception pour `db.env.example`.
- `README.md` §1 : parcours de démarrage adapté au projet déjà configuré,
  et tableau expliquant où vivent les secrets.
- `docs/SUPABASE_SETUP.md` : encart d'état en tête, voie scriptée en §3.
- `docs/STATUS.md` : les identifiants fournis n'ont pas pu être testés
  (proxy sortant : `x-deny-reason: host_not_allowed`).
- `analysis_options.yaml` : jeu de lints restreint aux règles utiles.
- Tests : casts explicitement typés (`Ok<dynamic>` / `Err<dynamic>`).


Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

## [1.0.0] — 2026-09-10

### Ajouté
- Authentification Supabase (inscription, connexion, déconnexion) via les
  endpoints GoTrue appelés en REST.
- Intercepteur Dio : injection `apikey` + `Bearer`, refresh proactif et
  réactif sur 401, déconnexion propre si le refresh échoue.
- Quatre écrans de données REST : catalogue, détail, favoris, profil.
- Cache local Hive CE (JSON encodé) et mode hors-ligne avec bandeau daté.
- Traduction centralisée des erreurs réseau (`ErrorMapper`).
- Schéma PostgreSQL avec Row Level Security et trigger de création de profil.
- Tests unitaires sur les repositories `movies`, `favorites`, `auth` et sur
  `ErrorMapper`.
- Documentation : architecture, API, configuration Supabase, dépannage, ADR.

### Non vérifié
- Compilation, exécution des tests et essais contre une instance Supabase
  réelle. Voir `docs/STATUS.md`.
