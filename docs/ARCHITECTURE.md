# Architecture

## 1. Vue d'ensemble

Organisation **feature-first** ; chaque feature applique les trois couches de
la Clean Architecture.

```
┌──────────────────────────────────────────────────────────┐
│ presentation   écrans, contrôleurs (ChangeNotifier)      │
│                ne connaît que domain/                     │
├──────────────────────────────────────────────────────────┤
│ domain         entités + interfaces de repository         │
│                ZÉRO import Dio / Hive / Flutter           │
├──────────────────────────────────────────────────────────┤
│ data           data sources (remote + local),             │
│                DTO, implémentation du repository          │
└──────────────────────────────────────────────────────────┘
        core/  : config, réseau, session, stockage, erreurs
```

Règle de dépendance : `presentation → domain ← data`. `domain` ne dépend de
rien. `core` est transverse et ne dépend d'aucune feature — c'est pourquoi
`AuthSession` vit dans `core/session/` et non dans `features/auth/`
(l'intercepteur en a besoin, or `core` ne peut pas importer `features`).

## 2. Flux d'une lecture de données

```
MoviesScreen
   └─ MoviesController.load()
        └─ MovieRepository.getMovies()          (interface, domain)
             └─ MovieRepositoryImpl             (data)
                  ├─ NetworkInfo.isConnected
                  ├─ hors ligne ──► MovieLocalDataSource.readMovies()   (Hive)
                  └─ en ligne   ──► MovieRemoteDataSource.fetchMovies() (Dio)
                                      └─ AuthInterceptor : apikey + Bearer
                                    puis écriture du cache Hive
             ◄── Result<Cached<List<Movie>>>
        └─ AsyncState (loading / ready / error, fromCache, syncedAt)
   └─ AsyncView : spinner | ErrorView | contenu + OfflineBanner
```

Aucune couche ne saute une étape : un écran n'appelle jamais Dio, un data
source ne connaît jamais `Failure`.

## 3. Conversion des erreurs

```
data source   lève   ServerException / NetworkException / UnauthorizedException
repository    attrape et convertit via ErrorMapper
              renvoie Err(Failure)
presentation  affiche Failure.message
```

Une `Exception` ne franchit jamais la frontière `data → presentation`. C'est
ce qui garantit qu'aucun `DioException.toString()` ne peut apparaître à
l'écran.

## 4. Injection de dépendances

`bootstrap.dart` est l'unique composition root. Il construit dans l'ordre :

```
AppConfig → Hive → FlutterSecureStorage → SessionManager
          → DioFactory → authDio → AuthRemoteDataSource (= TokenRefresher)
          → apiDio (avec AuthInterceptor)
          → data sources → repositories → contrôleurs → MultiProvider
```

Aucun singleton statique : chaque dépendance est passée par constructeur, donc
remplaçable par un mock dans les tests. C'est ce qui permet aux tests de la
couche repository de tourner sans Flutter engine.

## 5. Gestion d'état

`provider` + `ChangeNotifier`. Choix justifié dans
[`ADR-003`](decisions/ADR-003-etat-provider.md).

Tous les contrôleurs de données exposent un `AsyncState<T>` uniforme
(`status`, `data`, `failure`, `fromCache`, `syncedAt`), ce qui permet à
`AsyncView<T>` d'être le seul widget décidant quoi afficher.

## 6. Conventions

| Sujet | Convention |
|---|---|
| Nommage fichiers | `snake_case.dart` |
| Interfaces | `abstract interface class XRepository` |
| Implémentations | `XRepositoryImpl` |
| DTO | classes utilitaires statiques `XDto.fromJson` |
| Taille de fichier | viser < 250 lignes ; découper au-delà |
| Commentaires | expliquer le *pourquoi*, jamais paraphraser le code |
| Messages utilisateur | uniquement dans `ErrorMapper` et les repositories |

## 7. Points d'extension

| Besoin | Où intervenir |
|---|---|
| Nouvelle feature | `lib/features/<nom>/{data,domain,presentation}` + enregistrement dans `bootstrap.dart` |
| Changer de backend | 4 fichiers `*_remote_data_source.dart` + `AppConfig` |
| Changer de cache | `core/storage/json_box_store.dart` + les `*_local_data_source.dart` |
| Changer de gestion d'état | `presentation/controllers/` uniquement |
| Ajouter la synchro différée | file d'opérations dans `core/storage/` consommée par les repositories |
