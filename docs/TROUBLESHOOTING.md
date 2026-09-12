# Dépannage

Format : symptôme → cause → diagnostic → solution → prévention.

---

## `StateError: Configuration manquante` au lancement

- **Cause** : l'application a été lancée sans `--dart-define-from-file`.
- **Diagnostic** : `env.json` existe-t-il à la racine ?
- **Solution** :
  `cp env.example.json env.json` puis
  `flutter run --dart-define-from-file=env.json`.
  Dans VS Code, ajouter dans `.vscode/launch.json` :
  `"args": ["--dart-define-from-file=env.json"]`.
- **Prévention** : l'échec est volontairement immédiat et explicite plutôt
  qu'une 401 incompréhensible plus tard.

---

## 401 sur toutes les requêtes `/rest/v1`

- **Causes possibles** : `apikey` absent, clé erronée, ou clé héritée
  désactivée dans le dashboard.
- **Diagnostic** : rejouer la requête en `curl` (voir `SUPABASE_SETUP.md` §7).
- **Solution** : vérifier `SUPABASE_KEY`. Utiliser la clé **publiable**
  (`sb_publishable_...`), jamais une clé secrète.

---

## `[]` renvoyé alors que la table contient des lignes

- **Cause** : politique RLS absente ou trop restrictive. PostgREST renvoie un
  tableau vide, pas une erreur.
- **Diagnostic** : dans le SQL Editor,
  `select * from pg_policies where tablename = 'movies';`
- **Solution** : rejouer `supabase/schema.sql`.

---

## 404 sur une table qui existe

- **Cause** : le cache de schéma PostgREST n'a pas été rechargé.
- **Solution** : exécuter `notify pgrst, 'reload schema';` (déjà présent en
  fin de `schema.sql`).

---

## L'inscription réussit mais aucune session n'est ouverte

- **Cause** : « Confirm email » est activé (comportement normal).
- **Solution** : confirmer l'e-mail, ou désactiver l'option pour le
  développement (Authentication → Sign In / Providers → Email).

---

## Le profil n'est pas créé après l'inscription

- **Cause** : le trigger `on_auth_user_created` n'existe pas.
- **Diagnostic** :
  `select tgname from pg_trigger where tgname = 'on_auth_user_created';`
- **Solution** : rejouer la section 2 de `schema.sql`.

---

## Le refresh token ne se déclenche jamais / boucle de déconnexions

- **Diagnostic** : réduire la durée de vie de l'access token à 60 s
  (Authentication → Sessions), puis observer les logs `[dio]` en debug.
- **Causes fréquentes** :
  - horloge de l'appareil désynchronisée → `isExpired()` incohérent ;
  - refresh token déjà consommé par une autre instance de l'application
    (rotation GoTrue) ;
  - `AuthInterceptor` ajouté au mauvais client Dio (il ne doit **jamais**
    être attaché au client `/auth/v1`).

---

## Android : `MissingPluginException` sur flutter_secure_storage

- **Cause** : `minSdkVersion` inférieur à 18, ou build à chaud après ajout du
  plugin.
- **Solution** : porter `minSdkVersion` à 21 dans
  `android/app/build.gradle`, puis **arrêter et relancer** l'application
  (un hot restart ne recharge pas le code natif).

---

## Linux : échec de flutter_secure_storage

- **Cause** : `libsecret` absent.
- **Solution** : `sudo apt-get install libsecret-1-dev libsecret-1-0`.

---

## `HiveError: Box not found` / `Box has already been closed`

- **Cause** : accès à une boîte avant `initHive()`.
- **Solution** : toute lecture doit passer par un data source construit après
  `bootstrap()`. Ne jamais appeler `Hive.box(...)` depuis un `initState`
  exécuté avant l'initialisation.

---

## Les données du cache ne se mettent pas à jour

- **Cause** : le nom de boîte est versionné (`movies_cache_v1`). Un
  changement de format doit s'accompagner d'un incrément de version.
- **Solution** : incrémenter le suffixe dans `core/storage/hive_boxes.dart`
  et ajouter l'ancien nom à une routine de nettoyage.

---

## Le mode hors-ligne ne se déclenche pas alors qu'il n'y a pas d'Internet

- **Cause** : `connectivity_plus` indique l'état de l'interface réseau, pas
  l'accès effectif à Internet (Wi-Fi d'hôtel, portail captif, VPN).
- **Comportement attendu** : le repository bascule quand même sur le cache
  après l'échec de la requête (règle R4). Si rien ne s'affiche, c'est que le
  cache est vide.
