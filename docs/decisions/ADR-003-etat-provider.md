# ADR-003 — Gestion d'état avec `provider` + `ChangeNotifier`

## Contexte

Le sujet n'impose aucune solution de gestion d'état, mais exige une
architecture testable où la couche présentation ne connaît que le domaine.
Il faut aussi une injection de dépendances substituable en test.

## Décision

Utiliser **`provider`** pour l'injection et **`ChangeNotifier`** pour l'état,
avec un type d'état uniforme `AsyncState<T>`.

## Alternatives envisagées

1. **`flutter_bloc`** — excellent pour des machines à états complexes ;
   ici, chaque écran a le même cycle « charger / afficher / erreur », et
   l'écriture des Events/States serait du bruit.
2. **`riverpod`** — plus puissant, mais introduit un modèle mental
   supplémentaire (providers globaux, `ref`) et une surface d'API qui évolue
   entre versions majeures.
3. **`get_it` seul** — résout l'injection mais pas l'état, et repose sur un
   registre global : les tests doivent le réinitialiser entre chaque cas.

## Raisons

- `provider` fournit l'injection **et** l'écoute avec une seule dépendance.
- `ChangeNotifier` fait partie du SDK Flutter : aucune API tierce à apprendre.
- Les contrôleurs restent de simples classes Dart, testables sans widget.
- `AsyncState<T>` uniformise les états, ce qui permet à un unique widget
  `AsyncView<T>` de gérer chargement, erreur, contenu et bandeau hors-ligne.

## Conséquences

**Positives** — peu de code, montée en charge facile, dépendances réduites.

**Négatives** — `notifyListeners()` reconstruit tous les écouteurs (pas de
sélecteur fin par défaut) ; il faut penser à ne pas appeler `notifyListeners`
pendant un `build` (d'où les `addPostFrameCallback` dans `HomeShell`).

## Évolution

Si des états concurrents apparaissent (uploads multiples, websockets,
annulation de requêtes), migrer vers Bloc ou Riverpod. L'impact serait limité
à `presentation/controllers/`, les repositories restant inchangés.
