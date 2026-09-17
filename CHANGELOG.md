# Changelog

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
Versionnage : [SemVer](https://semver.org/lang/fr/).

---

## [1.2.1] — 2026-09-17

### Corrigé

- `HomeShell.didChangeDependencies` appelait `bindUser()` de façon synchrone.
  Cette méthode s'exécute pendant la phase de construction ; le
  `notifyListeners()` qui la termine demandait à Provider de marquer ses
  descendants comme « à reconstruire » en plein build, ce qui déclenchait
  `setState() or markNeedsBuild() called during build`. Les deux appels sont
  désormais reportés dans le `addPostFrameCallback` qui portait déjà les
  chargements. Bug présent depuis la version 1.0.0, resté invisible faute de
  test montant `HomeShell` — révélé par les tests d'intégration.

### Modifié

- CI : les tests d'intégration s'exécutent sur la cible Linux desktop via
  `xvfb-run` et `-d linux`. La note de la version 1.2.0 affirmant qu'ils
  tournaient sans appareil dans la VM `flutter_tester` était **erronée** :
  l'outillage Flutter exige un appareil dès que le chemin de test est
  `integration_test/`, et le runner en expose deux (Linux et Chrome), d'où
  l'erreur « More than one device connected ».
- `l10n.yaml` : suppression de `synthetic-package`, sans effet et signalée
  comme obsolète par les versions récentes de Flutter.

---

## [1.2.0] — 2026-09-15

Passage au niveau *production-ready* : internationalisation, accessibilité,
optimisation du rendu, suite de tests à trois niveaux et CI complète.

### Ajouté

- **Internationalisation français / anglais.** Pipeline officiel ARB +
  `flutter gen-l10n`, 67 messages, chaque clé du fichier modèle documentée.
  Configuration non synthétique (`synthetic-package: false`,
  `output-dir: lib/l10n`), conforme à la suppression de
  `package:flutter_gen` intervenue dans Flutter 3.32.0 stable.
- `LocaleController` et sélecteur de langue dans l'écran Profil
  (`Système` / `Français` / `English`).
- `FailureCode` : identifiant d'échec indépendant de la langue, posé par
  `ErrorMapper` et par les quatre dépôts. `core/l10n/failure_l10n.dart` en
  fait la traduction via un `switch` exhaustif — ajouter un code sans sa
  traduction devient une erreur de compilation.
- `AuthNotice` : remplace les phrases françaises que `AuthController`
  fabriquait lui-même.
- `PosterImage` : décodage à la taille d'affichage (`cacheWidth` /
  `cacheHeight` × `devicePixelRatio`), placeholder de dimensions identiques à
  l'image finale, `gaplessPlayback`, apparition en fondu, `semanticLabel`.
- `app_providers.dart` : arbre de providers extrait de `bootstrap.dart`, ce
  qui permet aux tests d'intégration de monter l'application réelle en ne
  remplaçant que les interfaces de `domain/`.
- **34 tests unitaires supplémentaires** sur les quatre contrôleurs
  (`movies`, `favorites`, `auth`, `profile`) — total : 65.
- **31 tests de widgets** (`test/widgets/`) : carte de film, vue d'erreur,
  bandeau hors ligne, vue asynchrone, écran de connexion, catalogue.
- **4 tests d'intégration** (`integration_test/`) : parcours de connexion,
  navigation catalogue → détail, synchronisation des favoris entre onglets,
  changement de langue à chaud.
- `test/support/fakes.dart` et `test/support/harness.dart` : doubles en
  mémoire et harnais de montage partagés entre widgets et intégration.
- Job CI `build-apk` : APK de démonstration publié en artefact de chaque
  build verte.
- `docs/screenshots/README.md` : procédure de capture pour le README.

### Modifié

- **Accessibilité.** Étiquettes sémantiques sur tous les éléments
  interactifs. Une carte de film expose désormais un nœud unique au lieu de
  quatre. Le bouton favori est sorti de la zone tactile de la carte : un
  appui dessus n'ouvre plus la fiche. `liveRegion` sur les erreurs, les
  notices et le bandeau hors ligne. `semanticsLabel` sur tous les
  indicateurs de progression.
- **Reconstructions.** `MoviesScreen` n'écoute plus aucun contrôleur ; chaque
  carte n'écoute qu'un booléen via `context.select`. `AuthGate` n'écoute que
  `AuthStatus`, `CineClubApp` que la `Locale`. Mettre un film en favori
  reconstruit une carte au lieu de l'écran entier.
- `FavoritesController.favoriteMovieIds` est mémorisé au lieu d'être
  reconstruit à chaque lecture : le coût d'une notification passe de
  O(favoris × cartes) à O(favoris).
- Dates et nombres formatés par `intl` avec la locale active
  (`15/01/2026 10:30` en FR, `1/15/2026 10:30 AM` en EN ; note `8,3` / `8.3`).
- **CI durcie** : version de Flutter figée, cache des dépendances,
  `dart format` redevenu bloquant, `flutter gen-l10n` rejoué, couverture
  publiée en artefact, tests d'intégration exécutés sans émulateur.
- `analysis_options.yaml` : ajout de `use_build_context_synchronously` ;
  exclusion du code généré par `gen-l10n`.
- README : badges, section captures d'écran, et quatre sections nouvelles
  (internationalisation, accessibilité, performance, intégration continue).

### Supprimé

- Toutes les chaînes d'interface codées en dur dans `lib/` — vérifié par
  `grep -rn "Text('" lib/`, qui ne retourne plus rien.
- `continue-on-error` sur l'étape de format de la CI, qui revenait à ne pas
  l'exécuter.

### Non vérifié

- `flutter analyze`, `flutter test` et `flutter test integration_test` n'ont
  **pas** été exécutés pour cette version : les modifications ont été
  produites dans un environnement dépourvu du SDK Flutter. La première
  exécution de la CI fait foi. Voir `docs/STATUS.md`.

---

## [1.1.0] — 2026-09-11

### Ajouté

- `env.json` renseigné avec le projet Supabase (URL + clé publiable), non
  versionné.
- `supabase/db.env` : chaîne de connexion PostgreSQL réservée aux scripts
  d'administration, séparée de la configuration de l'application — le client
  Flutter n'y accède jamais. Gabarit versionné dans `db.env.example`.
- `supabase/apply_schema.sh` : application de `schema.sql` puis `seed.sql`
  via psql, mot de passe lu depuis l'environnement (`ON_ERROR_STOP=1`).
- `supabase/smoke_test.sh` : vérification du backend en quatre appels curl
  (lecture publique, RLS anonyme, inscription, lecture authentifiée).

### Modifié

- `.gitignore` : ajout de `supabase/db.env`, exception pour `db.env.example`.
- README § 1 : parcours de démarrage adapté au projet déjà configuré, et
  tableau indiquant où vivent les secrets.
- `docs/SUPABASE_SETUP.md` : encart d'état en tête, voie scriptée en § 3.
- `analysis_options.yaml` : jeu de lints restreint aux règles utiles.
- Code Dart dépouillé de ses commentaires redondants : 158 blocs sur 177
  retirés. Les 19 conservés expliquent un choix qu'aucune relecture du code
  ne permet de retrouver (sérialisation des refresh par `QueuedInterceptor`,
  règles R1–R5 du mode hors-ligne, en-tête `apikey` exigé par PostgREST,
  `Prefer: return=representation`, 401 jamais masqué par le cache).

### Corrigé

- `error_mapper.dart` : `DioExceptionType.transformTimeout` manquant dans le
  `switch` exhaustif — seule erreur de compilation du projet.
- `exceptions.dart` : `UnauthorizedException` passé en paramètres `super.`
  avec `super.statusCode = 401` (lint `use_super_parameters`).
- `movie_dto.dart` : `final` sur les variables de motif
  (lint `prefer_final_locals`).

---

## [1.0.0] — 2026-09-10

Première version fonctionnelle.

### Ajouté

- Authentification Supabase (inscription, connexion, déconnexion) via les
  endpoints GoTrue appelés en REST, sans le SDK `supabase_flutter`.
- Intercepteur Dio : injection `apikey` + `Bearer`, refresh proactif et
  réactif sur 401, déconnexion propre si le refresh échoue. Basé sur
  `QueuedInterceptor` pour éviter les refresh concurrents.
- Quatre écrans de données REST : catalogue, détail, favoris, profil, plus
  connexion et inscription.
- Cache local Hive CE (JSON encodé) et mode hors-ligne avec bandeau daté.
- Traduction centralisée des erreurs réseau (`ErrorMapper`).
- Schéma PostgreSQL avec Row Level Security et trigger de création de profil.
- Tests unitaires sur les dépôts `movies`, `favorites`, `auth` et sur
  `ErrorMapper` (31 tests).
- Documentation : architecture, API, configuration Supabase, dépannage, ADR.

### Non vérifié

- Compilation, exécution des tests et essais contre une instance Supabase
  réelle. Voir `docs/STATUS.md`.

[1.2.0]: https://github.com/OWNER/REPO/releases/tag/v1.2.0
[1.1.0]: https://github.com/OWNER/REPO/releases/tag/v1.1.0
[1.0.0]: https://github.com/OWNER/REPO/releases/tag/v1.0.0
