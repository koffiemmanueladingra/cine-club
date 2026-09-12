# CinéClub — application Flutter full-stack

Application Flutter connectée à un backend **Supabase** (authentification JWT +
API REST PostgREST), avec **cache local Hive CE** et **mode hors-ligne**.

| Exigence du sujet | Où c'est implémenté |
|---|---|
| Authentification (login / register / logout) — JWT | `lib/features/auth/`, endpoints GoTrue |
| ≥ 3 écrans de données issues d'une API REST | Catalogue, Détail film, Favoris, Profil (4 écrans) |
| Cache local (Hive) | `lib/core/storage/`, `*_local_data_source.dart` |
| Mode hors-ligne | `*_repository_impl.dart` + `OfflineBanner` |
| Gestion d'erreurs réseau avec messages utilisateur | `lib/core/network/error_mapper.dart`, `ErrorView` |
| Architecture Clean + Feature-First | `lib/core/` + `lib/features/<feature>/{data,domain,presentation}` |
| Repository pattern | interface dans `domain/repositories/`, implémentation dans `data/repositories/` |
| Dio | `lib/core/network/dio_factory.dart` |
| Intercepteur d'injection du token | `lib/core/network/auth_interceptor.dart` |
| Gestion du refresh token | même fichier (proactif + réactif sur 401) |
| ≥ 3 tests unitaires sur la couche repository | `test/features/*/data/*_repository_impl_test.dart` |

---

## 1. Démarrage rapide

Le projet Supabase `qkzpjimpmehmfqzgzuqy` est déjà renseigné dans `env.json`
et `supabase/db.env` (deux fichiers **non versionnés**). Il reste à créer le
schéma côté serveur.

```bash
# 1. Dépendances
flutter pub get

# 2. Schéma + données de démonstration
source supabase/db.env && ./supabase/apply_schema.sh
#    (ou : coller supabase/schema.sql puis seed.sql dans le SQL Editor)

# 3. Authentification : désactiver « Confirm email »
#    Dashboard > Authentication > Providers > Email  (sinon pas de token
#    à l'inscription et l'écran de connexion restera bloqué)

# 4. Vérification du backend, sans lancer Flutter
./supabase/smoke_test.sh

# 5. Lancement
flutter run --dart-define-from-file=env.json

# 6. Tests unitaires (aucun réseau requis)
flutter test
```

### Où vivent les secrets

| Fichier | Contenu | Versionné | Lu par |
|---|---|---|---|
| `env.json` | URL + clé publiable | non | l'app, via `--dart-define-from-file` |
| `env.example.json` | gabarit | oui | — |
| `supabase/db.env` | chaîne PostgreSQL + mot de passe | non | `apply_schema.sh` uniquement |
| `supabase/db.env.example` | gabarit | oui | — |

La **clé publiable est publique par conception** : elle identifie le projet,
elle n'autorise rien. Toute la protection repose sur les politiques RLS de
`supabase/schema.sql`. Le **mot de passe PostgreSQL, lui, est un secret
critique** : il donne un accès `postgres` complet qui contourne la RLS. Il
n'est jamais lu par l'application Flutter et ne doit jamais l'être — le
client mobile passe exclusivement par PostgREST.

Aucune clé n'est écrite en dur dans le code : `AppConfig.fromDartDefine()`
échoue explicitement au démarrage si la configuration manque.

---

## 2. Architecture

Organisation **feature-first**, chaque feature étant découpée en trois couches
Clean Architecture. Le sens des dépendances est toujours le même :

```
presentation ──► domain ◄── data
                  ▲
                  │  (aucune dépendance sortante)
             core (transverse)
```

```
lib/
├── core/                        # transverse, ne dépend d'aucune feature
│   ├── config/                  # AppConfig (dart-define)
│   ├── error/                   # Failure, Exception, Result, Cached
│   ├── network/                 # DioFactory, AuthInterceptor, ErrorMapper, NetworkInfo
│   ├── session/                 # AuthSession, SessionManager, TokenRefresher
│   ├── storage/                 # boîtes Hive, JsonBoxStore
│   ├── state/                   # AsyncState
│   └── widgets/                 # AsyncView, OfflineBanner, ErrorView
├── features/
│   ├── auth/       {data,domain,presentation}
│   ├── movies/     {data,domain,presentation}
│   ├── favorites/  {data,domain,presentation}
│   └── profile/    {data,domain,presentation}
├── app.dart                     # thème + aiguillage AuthGate
├── bootstrap.dart               # composition root (seule injection concrète)
└── main.dart
```

**Règles appliquées**

- `domain/` ne contient que des entités et des interfaces : aucun import de
  Dio, Hive ou Flutter. C'est ce qui rend les tests indépendants des plugins.
- `data/` contient les *data sources* (un remote, un local) et
  l'implémentation du repository. Elle traduit les `Exception` en `Failure`.
- `presentation/` ne connaît que les interfaces `domain` et manipule
  uniquement des `Failure` déjà rédigées en français.
- Une seule composition root : `bootstrap.dart`. Aucun singleton global,
  aucun `GetIt` — les dépendances sont fournies par `provider` et donc
  substituables en test.

Détails et diagrammes : [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## 3. APIs utilisées

Backend : **Supabase** (PostgreSQL + GoTrue + PostgREST). Les appels sont
faits directement en REST avec Dio, **sans le SDK `supabase_flutter`** : le
sujet demande un intercepteur et une gestion explicite du refresh token, que
le SDK masquerait entièrement.

### Authentification — `<SUPABASE_URL>/auth/v1`

| Méthode | Endpoint | Usage |
|---|---|---|
| POST | `/signup` | inscription (`data.display_name` → métadonnées) |
| POST | `/token?grant_type=password` | connexion |
| POST | `/token?grant_type=refresh_token` | renouvellement du token |
| POST | `/logout` | révocation de la session |

### Données — `<SUPABASE_URL>/rest/v1`

| Méthode | Endpoint | Écran |
|---|---|---|
| GET | `/movies?select=*&order=release_year.desc` | Catalogue |
| GET | `/movies?select=*&id=eq.<uuid>` | Détail |
| GET | `/favorites?select=id,created_at,movie:movies(*)&order=created_at.desc` | Favoris |
| POST | `/favorites` (corps `{"movie_id": "<uuid>"}`) | Ajout favori |
| DELETE | `/favorites?movie_id=eq.<uuid>` | Retrait favori |
| GET | `/profiles?select=*&id=eq.<uuid>` | Profil |
| PATCH | `/profiles?id=eq.<uuid>` | Mise à jour du profil |

Contrat détaillé (corps, codes d'erreur) : [`docs/API.md`](docs/API.md).

---

## 4. Authentification et refresh token

Deux clients Dio distincts, construits par `DioFactory` :

- `createAuthClient()` → `/auth/v1`, **sans** intercepteur. Un 401 y signifie
  « mauvais mot de passe », pas « token à rafraîchir ».
- `createApiClient()` → `/rest/v1`, **avec** `AuthInterceptor`.

`AuthInterceptor` étend `QueuedInterceptor` (et non `Interceptor`) : les
callbacks sont sérialisés, donc trois requêtes recevant trois 401 en parallèle
ne déclenchent pas trois refresh concurrents — ce qui invaliderait le refresh
token par rotation côté GoTrue.

```
onRequest  ──► apikey + Bearer <access_token>
           └─► si token expiré : refresh AVANT envoi (évite un 401 inutile)

onError(401, non rejouée)
           ──► refresh
                ├── succès : marque la requête, rejoue via un Dio « nu », resolve
                └── échec  : SessionManager.clear() → AuthGate revient au login
```

Les tokens sont stockés par `flutter_secure_storage` (Keychain iOS /
EncryptedSharedPreferences Android), **jamais dans Hive** : un fichier Hive est
lisible en clair sur un appareil rooté.

---

## 5. Cache local et mode hors-ligne

Hive CE (`hive_ce` / `hive_ce_flutter`) — voir
[`ADR-002`](docs/decisions/ADR-002-cache-hive-ce.md) pour le choix du fork.

Les boîtes sont des `Box<String>` contenant du **JSON encodé**, au format exact
de l'API : un seul mapping à maintenir, aucun `build_runner`, et aucun crash de
migration si un champ change côté serveur.

Stratégie identique dans les trois repositories de données :

| Situation | Comportement |
|---|---|
| Hors ligne, cache présent | Succès, `fromCache = true`, bandeau + date de synchro |
| Hors ligne, cache vide | `EmptyCacheFailure` + message explicite |
| En ligne, requête OK | Succès réseau, réécriture du cache |
| En ligne, requête KO, cache présent | Succès depuis le cache (dégradé) |
| En ligne, requête KO, cache vide | `Failure` traduite par `ErrorMapper` |
| 401 non récupérable | **jamais** masqué par le cache → retour au login |

Les **écritures** (ajout/retrait de favori, édition du profil) exigent le
réseau et renvoient une `NetworkFailure` explicite hors ligne : aucune file de
synchronisation différée n'est implémentée
([`ADR-004`](docs/decisions/ADR-004-favoris-hors-ligne.md)).

Au logout, `clearAllCaches()` vide toutes les boîtes : sur un appareil partagé,
les données d'un utilisateur ne restent pas lisibles par le suivant.

---

## 6. Gestion des erreurs

Une seule traduction, dans `core/network/error_mapper.dart` :

```
DioException / AppException  ──► Failure (message français)  ──► ErrorView / SnackBar
```

- `NetworkFailure` — timeout, DNS, socket, certificat.
- `ServerFailure` — 4xx/5xx (message serveur repris si exploitable ; message
  générique au-delà de 500 pour ne pas exposer de détail interne).
- `AuthFailure` — 401/403. Identifiants invalides → message volontairement
  générique, pour ne pas permettre l'énumération de comptes.
- `CacheFailure` / `EmptyCacheFailure` — problèmes de stockage local.

GoTrue et PostgREST n'utilisent pas les mêmes clés d'erreur
(`msg` / `error_description` d'un côté, `message` de l'autre) :
`extractServerMessage` gère les deux, ce qui est couvert par les tests.

---

## 7. Tests

```bash
flutter test
```

| Fichier | Couverture |
|---|---|
| `test/features/movies/data/movie_repository_impl_test.dart` | 5 règles offline-first, 401 non masqué, cache corrompu, détail |
| `test/features/favorites/data/favorite_repository_impl_test.dart` | lecture offline-first, refus des mutations hors ligne, resynchro |
| `test/features/auth/data/auth_repository_impl_test.dart` | persistance de session, message générique, logout garanti |
| `test/core/network/error_mapper_test.dart` | mapping des familles d'erreurs, extraction du message serveur |

Mocks via **mocktail** : aucun code généré, aucun `build_runner`. Les tests
n'ouvrent ni socket ni boîte Hive — ils s'exécutent en CI sans appareil.

---

## 8. Compatibilité

| Plateforme | État | Remarque |
|---|---|---|
| Android | supporté | `minSdkVersion` ≥ 18 requis par `flutter_secure_storage` |
| iOS | supporté | Keychain, aucune configuration supplémentaire |
| Windows / macOS | supporté | — |
| Linux | supporté | `libsecret-1-dev` requis pour `flutter_secure_storage` |
| Web | non ciblé | `flutter_secure_storage` y stocke en clair (`localStorage`) |

Aucun chemin de fichier n'est écrit en dur : Hive utilise
`path_provider` via `Hive.initFlutter()`.

Problèmes fréquents : [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

---

## 9. Documentation

| Document | Contenu |
|---|---|
| [`docs/SUPABASE_SETUP.md`](docs/SUPABASE_SETUP.md) | **Configuration complète du backend, pas à pas** |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Couches, flux de données, conventions |
| [`docs/API.md`](docs/API.md) | Contrat REST détaillé |
| [`docs/FEATURES_MATRIX.md`](docs/FEATURES_MATRIX.md) | Matrice de suivi des fonctionnalités |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Symptôme / cause / solution |
| [`docs/decisions/`](docs/decisions/) | ADR (décisions techniques justifiées) |
| [`docs/STATUS.md`](docs/STATUS.md) | **État réel de vérification du projet** |

> `docs/STATUS.md` indique précisément ce qui a été vérifié et ce qui ne l'a
> pas été. À lire avant de considérer une fonctionnalité comme validée.
