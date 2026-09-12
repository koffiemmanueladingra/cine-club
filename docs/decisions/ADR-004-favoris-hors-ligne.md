# ADR-004 — Pas de file de synchronisation différée pour les favoris

## Contexte

Le mode hors-ligne est exigé pour l'**affichage** des données. Se pose la
question des **écritures** (ajout/retrait d'un favori, édition du profil)
effectuées sans réseau.

## Décision

Les mutations exigent le réseau. Hors ligne, le repository renvoie une
`NetworkFailure` avec un message explicite ; aucune opération n'est mise en
file d'attente.

## Alternatives envisagées

1. **File d'attente locale rejouée à la reconnexion** — confort utilisateur
   supérieur, mais impose : persistance des opérations, déduplication,
   ordonnancement, résolution de conflits (favori supprimé sur un autre
   appareil), et gestion des échecs définitifs.
2. **Mise à jour optimiste sans file** — l'interface afficherait un favori qui
   n'existe pas côté serveur, puis reviendrait en arrière au prochain
   chargement : le pire des deux mondes.

## Raisons

- Le sujet demande « afficher les données cachées si pas de réseau », pas
  d'écrire hors ligne.
- Un mensonge d'interface (« ajouté ») suivi d'une disparition silencieuse est
  plus grave qu'un refus clair et immédiat.
- La complexité d'une file de synchronisation dépasse largement le périmètre
  et introduirait des cas limites non testés.

## Conséquences

**Positives** — comportement prévisible, cache local toujours conforme au
serveur, aucun état intermédiaire à gérer.

**Négatives** — l'utilisateur hors ligne ne peut pas préparer sa liste de
favoris.

## Évolution

Si le besoin apparaît : ajouter une boîte Hive `pending_operations`
(opération, cible, horodatage), la rejouer sur `NetworkInfo.onStatusChange`,
et arbitrer les conflits au dernier écrivain. Le point d'entrée serait
`FavoriteRepositoryImpl._mutate`, déjà isolé pour cela.
