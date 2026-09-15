# État réel du projet

Date de rédaction : 10 septembre 2026.
Dernière mise à jour : 15 septembre 2026 (version 1.2.0 — i18n,
accessibilité, performance, tests widgets et intégration, CI).

> **Lisez le § 1 ter avant de considérer la version 1.2.0 comme validée.**
> Elle a été écrite sans SDK Flutter : rien n'y a été compilé ni exécuté.

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

## 1 ter. Version 1.2.0 (15/09/2026) — état de vérification

Écrite, comme les précédentes, **sans SDK Flutter à disposition**. Aucune des
commandes suivantes n'a été exécutée sur ce lot de modifications :

| Commande | Exécutée ? |
|---|---|
| `flutter pub get` | non |
| `flutter gen-l10n` | non |
| `dart format` | non |
| `flutter analyze` | non |
| `flutter test` | non |
| `flutter test integration_test` | non |

### Ce qui a malgré tout été vérifié mécaniquement

| Contrôle | Méthode | Résultat |
|---|---|---|
| Parité des traductions FR/EN | comparaison des clés des deux ARB | 67 clés des deux côtés, aucune manquante |
| Cohérence des placeholders | extraction des `{...}` par clé | identiques en FR et EN |
| Clés utilisées vs définies | balayage de `l10n.<clé>` dans tout le code | aucune clé absente, aucune clé orpheline |
| Classes générées complètes | recherche du getter ou de la méthode par clé | les 67 présentes |
| Imports | résolution de chaque import relatif et `package:cine_club/` | tous pointent sur un fichier existant |
| Équilibrage syntaxique | comptage accolades / parenthèses hors chaînes et commentaires | équilibré partout **après correction d'une apostrophe non échappée** dans un nom de test |
| Membres des doubles de test | croisement appels / déclarations dans `test/support/fakes.dart` | aucun membre appelé qui n'existe pas |
| Chaînes codées en dur | `grep -rn "Text('" lib/` | aucun résultat |
| Largeur des lignes | détection des lignes de code > 80 colonnes | 0 restante (hors imports et littéraux, que `dart format` ne réécrit pas) |

Ces contrôles réduisent le risque d'erreur grossière. **Ils ne remplacent pas
une compilation** : ils ne détectent ni une erreur de type, ni une signature
incorrecte, ni un `override` manquant.

### Points à traiter au premier passage sur une machine avec le SDK

1. **`dart format .` puis commit.** L'étape de format de la CI était
   auparavant en `continue-on-error`, donc jamais réellement appliquée : le
   dépôt contient probablement des fichiers non formatés. Elle est désormais
   bloquante, la CI sera rouge sinon.
2. **`pubspec.lock` est obsolète.** Il précède l'ajout de
   `flutter_localizations`, `intl` et `integration_test` ; `flutter pub get`
   le régénère.
3. **`flutter gen-l10n`.** Les classes de `lib/l10n/` ont été produites par un
   script reproduisant le format de l'outil, pas par l'outil lui-même. La
   régénération fait foi.
4. **Badge CI et captures d'écran.** Remplacer `OWNER/REPO` dans le README et
   produire les cinq images décrites dans `docs/screenshots/README.md`.


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
