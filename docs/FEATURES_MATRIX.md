# Matrice de suivi des fonctionnalités

Statuts autorisés : `Done`, `In Progress`, `Blocked`, `Needs Review`,
`Partially Implemented`.

> **Aucune ligne n'est encore marquée `Done`** — volontairement.
>
> Deux niveaux de preuve ont été obtenus le 11/09/2026 :
>
> | Preuve | Commande | Résultat |
> |---|---|---|
> | Analyse statique | `flutter analyze` | `No issues found` |
> | Tests unitaires | `flutter test` | `+31: All tests passed` |
>
> Ces deux preuves valident que le code **compile** et que la **logique de la
> couche repository** est conforme aux règles R1–R5. Elles ne valident aucune
> des vérifications de la dernière colonne, qui sont toutes comportementales
> et exigent une instance Supabase réelle et l'interface lancée. Un test qui
> passe sur un `MovieRepositoryImpl` avec sources de données simulées ne dit
> rien de l'affichage du catalogue ni de la RLS.
>
> Passez une ligne à `Done` après avoir exécuté **sa** vérification, pas
> avant.

| ID | Fonctionnalité | Backend | Client | Cache | Erreurs | Tests | Doc | Statut | Vérification à effectuer |
|---|---|---|---|---|---|---|---|---|---|
| AUTH-001 | Inscription | Oui | Oui | n/a | Oui | Oui | Oui | Needs Review | créer un compte, vérifier la ligne `profiles` |
| AUTH-002 | Connexion | Oui | Oui | n/a | Oui | Oui | Oui | Needs Review | se connecter, relancer l'app (session restaurée) |
| AUTH-003 | Déconnexion | Oui | Oui | Oui | Oui | Oui | Oui | Needs Review | logout → retour login, caches vidés |
| AUTH-004 | Injection du token | n/a | Oui | n/a | Oui | Non | Oui | Needs Review | inspecter les en-têtes d'une requête `/rest/v1` |
| AUTH-005 | Refresh token (proactif + 401) | Oui | Oui | n/a | Oui | Non | Oui | Needs Review | régler la durée d'access token à 60 s, attendre, agir |
| AUTH-006 | Déconnexion forcée si refresh KO | n/a | Oui | Oui | Oui | Non | Oui | Needs Review | révoquer la session côté dashboard |
| MOV-001 | Écran catalogue (REST) | Oui | Oui | Oui | Oui | Oui | Oui | Needs Review | 8 films affichés |
| MOV-002 | Écran détail | Oui | Oui | Oui | Oui | Oui | Oui | Needs Review | ouvrir une fiche |
| MOV-003 | Recherche locale | n/a | Oui | n/a | n/a | Non | Oui | Needs Review | filtrer par titre et par genre |
| FAV-001 | Écran favoris (REST + jointure) | Oui | Oui | Oui | Oui | Oui | Oui | Needs Review | liste vide puis peuplée |
| FAV-002 | Ajout / retrait favori | Oui | Oui | Oui | Oui | Oui | Oui | Needs Review | basculer le cœur, recharger |
| FAV-003 | Refus des mutations hors ligne | n/a | Oui | n/a | Oui | Oui | Oui | Needs Review | mode avion → SnackBar explicite |
| PRO-001 | Écran profil (REST) | Oui | Oui | Oui | Oui | Non | Oui | Needs Review | nom, e-mail, identifiant affichés |
| PRO-002 | Édition du nom affiché | Oui | Oui | Oui | Oui | Non | Oui | Needs Review | PATCH puis relecture |
| OFF-001 | Lecture depuis le cache hors ligne | n/a | Oui | Oui | Oui | Oui | Oui | Needs Review | charger en ligne, passer en mode avion, relancer |
| OFF-002 | Bandeau « mode hors ligne » + date | n/a | Oui | Oui | n/a | Non | Oui | Needs Review | bandeau visible avec date de synchro |
| OFF-003 | Cache vide hors ligne → message clair | n/a | Oui | Oui | Oui | Oui | Oui | Needs Review | première installation en mode avion |
| ERR-001 | Traduction centralisée des erreurs | n/a | Oui | n/a | Oui | Oui | Oui | Needs Review | couper le réseau pendant une requête |
| SEC-001 | RLS sur les 3 tables | Oui | n/a | n/a | Oui | Non | Oui | Needs Review | tests curl de `SUPABASE_SETUP.md` §7.2 |
| SEC-002 | Tokens en stockage chiffré | n/a | Oui | n/a | n/a | Non | Oui | Needs Review | vérifier l'absence de token dans les fichiers Hive |
| SEC-003 | Aucun secret dans le dépôt | n/a | Oui | n/a | n/a | Non | Oui | Needs Review | `git grep -i "sb_publishable\|sb_secret"` |

## Fonctionnalités volontairement hors périmètre

| Sujet | Raison |
|---|---|
| Synchronisation différée des favoris hors ligne | gestion de conflits hors périmètre — [`ADR-004`](decisions/ADR-004-favoris-hors-ligne.md) |
| OAuth (Google, Apple) | le sujet demande « JWT **ou** OAuth » ; JWT est implémenté |
| Réinitialisation de mot de passe | non demandé ; endpoint GoTrue `/recover` à ajouter le cas échéant |
| Pagination du catalogue | jeu de données de démonstration réduit ; `Range` PostgREST à ajouter au-delà de ~200 films |
| Tests de widgets / d'intégration | le sujet exige des tests unitaires sur la couche repository |
