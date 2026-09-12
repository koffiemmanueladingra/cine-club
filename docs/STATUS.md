# État réel du projet

Date de rédaction : 10 septembre 2026.
Dernière mise à jour : 11 septembre 2026 (ajout des identifiants du projet
Supabase `qkzpjimpmehmfqzgzuqy`).

## 1. Ce qui a été fait

- Écriture complète du code source, des tests, du schéma SQL et de la
  documentation.
- Vérification des points suivants auprès de sources en ligne au moment de la
  rédaction :
  - endpoints Supabase Auth (`/auth/v1/signup`, `/token?grant_type=password`,
    `/token?grant_type=refresh_token`, `/logout`) et en-tête `apikey` ;
  - dépréciation des clés `anon` / `service_role` au profit de
    `sb_publishable_...` / `sb_secret_...` ;
  - statut de Hive : `hive_ce` / `hive_ce_flutter` sont les paquets
    maintenus, avec l'import `package:hive_ce_flutter/hive_ce_flutter.dart` ;
  - `connectivity_plus` ≥ 6.0.0 : `checkConnectivity()` renvoie une
    `List<ConnectivityResult>`, jamais vide.

## 1 bis. Vérifications réussies le 11/09/2026

Effectuées par le commanditaire sur Windows, SDK Flutter local (l'auteur du
code n'a aucun SDK à disposition, voir §2).

| Vérification | Commande | Résultat |
|---|---|---|
| Résolution des dépendances | `flutter pub get` | `Got dependencies` |
| Analyse statique | `flutter analyze` | `No issues found` |
| Tests unitaires | `flutter test` | `+31: All tests passed` |

Trois correctifs ont été nécessaires pour y parvenir :
- `error_mapper.dart` : ajout de `DioExceptionType.transformTimeout`, absent
  de la version de Dio connue à la rédaction — le `switch` sur un enum sans
  clause `default` doit être exhaustif, d'où une erreur de compilation.
- `exceptions.dart` : `UnauthorizedException` convertie en paramètres `super.`
  avec `super.statusCode = 401` par défaut (`use_super_parameters`).
- `movie_dto.dart` : modificateur `final` sur les variables de motif des
  `switch` d'expression (`prefer_final_locals`).

Portée de ces preuves : le code compile et la logique de la couche repository
est conforme. Le comportement réel de l'intercepteur, du refresh, du cache
Hive et de la RLS reste **non vérifié** — ce sont des tests avec sources
simulées, sans réseau ni Hive.

## 2. Ce qui n'a PAS été vérifié

Ces points doivent être validés avant toute livraison :

| Point | Statut | Comment vérifier |
|---|---|---|
| Build Android / iOS | **non vérifié** | `flutter build apk --debug --dart-define-from-file=env.json` |
| Comportement contre un vrai projet Supabase | **non vérifié** | suivre `SUPABASE_SETUP.md` §7 |
| Validité de l'URL et de la clé publiable fournies | **non vérifié** | `./supabase/smoke_test.sh` |
| Application du schéma SQL sur le projet | **non fait** | `source supabase/db.env && ./supabase/apply_schema.sh` |
| Réglage « Confirm email » côté Supabase | **non fait** | Dashboard > Authentication > Providers > Email |
| Résolution exacte des versions de paquets | **non vérifié** | `flutter pub outdated` |

Aucun SDK Flutter n'était disponible dans l'environnement de rédaction : le
code n'a été ni compilé, ni exécuté, ni testé. Attendez-vous à devoir
corriger des erreurs de compilation résiduelles (imports, signatures d'API
ayant évolué).

### Pourquoi les identifiants n'ont pas été testés

L'environnement de rédaction n'a pas d'accès réseau vers `*.supabase.co` :
la requête de contrôle est rejetée par le proxy sortant avec l'en-tête
`x-deny-reason: host_not_allowed`, avant même d'atteindre Supabase. Le code
HTTP 403 obtenu vient donc du proxy, **pas** de Supabase : il ne dit rien sur
la validité de la clé. Aucune conclusion ne peut être tirée tant que
`smoke_test.sh` n'a pas été exécuté depuis un poste connecté.

## 3. Contraintes de versions

`pubspec.yaml` utilise des bornes basses volontairement prudentes
(`dio: ^5.4.0`, `hive_ce: ^2.8.0`, `connectivity_plus: ^6.0.0`,
`flutter_secure_storage: ^9.0.0`, `provider: ^6.1.0`, `mocktail: ^1.0.0`).
`pub` résoudra la version la plus récente compatible dans la même version
majeure. Si une version majeure supérieure est sortie depuis, exécuter :

```bash
flutter pub outdated
flutter pub upgrade --major-versions   # puis relire les changelogs
```

Points de rupture connus à surveiller :

- `flutter_secure_storage` v10 : `AndroidOptions.encryptedSharedPreferences`
  a évolué — voir `bootstrap.dart`.
- `connectivity_plus` v7 éventuel : revérifier le type de retour de
  `checkConnectivity()` dans `core/network/network_info.dart`.

## 3 bis. Écart assumé avec projet-ia.md

Les commentaires du code ont été retirés à la demande explicite du
commanditaire (11 % conservés). `projet-ia.md` impose une documentation par
fichier (responsabilité / dépendances / ne doit pas / évolution) et par
fonction (objectif / paramètres / retour / erreurs / effets de bord). Cet
écart est **volontaire et documenté**, il n'est pas un oubli. La version
conforme est conservée à l'identique dans `cine_club_documente.zip` ; la
documentation d'architecture (`docs/`) n'a pas été touchée.

## 4. Hypothèses

| Hypothèse | À confirmer |
|---|---|
| « Confirm email » désactivé côté Supabase en développement | réglage du dashboard ; les deux cas sont gérés par le code |
| Longueur minimale de mot de passe = 6 | doit rester alignée avec `register_screen.dart` |
| Catalogue de taille modeste (recherche et filtrage côté client) | ajouter la pagination `Range` au-delà de ~200 films |
| Un seul utilisateur connecté à la fois par appareil | le cache est cloisonné par `userId`, mais non chiffré |
