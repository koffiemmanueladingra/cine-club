# ADR-002 — Cache local avec Hive CE, en JSON encodé

## Contexte

Le sujet impose un cache local (Hive, Isar ou SQLite) et un mode hors-ligne.
Hive v2 (`hive` / `hive_flutter`) n'est plus maintenu : `hive_flutter` n'a pas
connu de version stable depuis plusieurs années, et son auteur s'est tourné
vers Isar puis Hive v4.

## Décision

1. Utiliser **Hive CE** (`hive_ce`, `hive_ce_flutter`), fork communautaire
   activement maintenu, présenté comme la continuation de Hive v2.
2. Stocker les données sous forme de **JSON encodé dans des `Box<String>`**,
   sans `TypeAdapter` ni génération de code.

## Alternatives envisagées

1. **`hive` / `hive_flutter` d'origine** — demandé par l'énoncé, mais non
   maintenu ; risque d'incompatibilité avec les versions récentes de Flutter.
2. **`TypeAdapter` générés par `hive_ce_generator` + `build_runner`** —
   stockage typé et compact, mais impose une étape de génération, un second
   mapping à maintenir en parallèle des DTO d'API, et un risque de
   `HiveError` au démarrage si un `typeId` change.
3. **SQLite (`sqflite`) / Isar** — SQLite est explicitement écarté par la
   consigne ; Isar apporte une complexité disproportionnée pour trois listes.

## Raisons

- Hive CE conserve l'API de Hive v2 : la consigne « faire avec Hive » est
  respectée, sans dépendre d'un paquet abandonné.
- Le format de cache est **identique** au format de l'API : un seul mapping
  (`MovieDto.fromJson`) sert au réseau et au cache. Moins de code, moins de
  divergences possibles.
- Un champ ajouté côté serveur n'invalide pas le cache : le JSON est
  simplement ignoré au parsing.
- Aucune étape `build_runner` : le projet se clone et se lance directement.

## Conséquences

**Positives** — mise en place simple, migrations triviales (versionner le nom
de boîte), aucun code généré.

**Négatives** — pas de requête indexée dans Hive (on relit une liste entière) ;
l'encodage JSON coûte un peu de CPU. Acceptable pour quelques centaines
d'éléments, à revoir au-delà.

**Sécurité** — les boîtes ne sont pas chiffrées. Les tokens sont donc stockés
dans `flutter_secure_storage`, jamais dans Hive.

## Évolution

Au-delà de quelques milliers d'enregistrements ou en cas de besoin de requêtes
locales complexes, migrer vers des `TypeAdapter` ou vers Isar. Le changement
resterait confiné à `core/storage/` et aux `*_local_data_source.dart`.
