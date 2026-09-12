# ADR-001 — Utiliser Supabase comme backend, appelé en REST brut

## Contexte

Le sujet impose une authentification JWT, au moins trois écrans alimentés par
une API REST, un intercepteur d'injection de token et la gestion du refresh
token. Il laisse le choix entre une API publique, Supabase, ou un backend
propre.

## Décision

Utiliser **Supabase** (PostgreSQL + GoTrue + PostgREST), interrogé
**directement en REST avec Dio**, sans le SDK `supabase_flutter`.

## Alternatives envisagées

1. **API publique (TMDB, OpenWeatherMap, NewsAPI)** — elles n'offrent pas
   d'authentification par utilisateur ni de refresh token : deux exigences du
   sujet seraient impossibles à satisfaire.
2. **Backend propre (Laravel / NestJS)** — répond au besoin mais ajoute un
   second projet à écrire, tester, héberger et documenter, sans rien apporter
   à l'évaluation, qui porte sur l'application Flutter.
3. **Supabase avec le SDK `supabase_flutter`** — le SDK gère lui-même le
   stockage des tokens et leur renouvellement. L'intercepteur et le refresh
   deviendraient invisibles, donc non démontrables.

## Raisons

- GoTrue expose un flux OAuth2 standard (`grant_type=password` /
  `grant_type=refresh_token`) : le code d'authentification reste
  transposable à n'importe quel backend.
- PostgREST fournit une vraie API REST avec filtres, tri et jointures.
- Row Level Security déplace l'autorisation côté base : la clé publique
  embarquée dans l'application ne donne aucun accès non autorisé.
- Appeler l'API en REST brut rend l'intercepteur et le refresh **visibles et
  testables**, ce qui est précisément l'objet de l'exercice.

## Conséquences

**Positives** — aucun serveur à maintenir ; le couplage à Supabase est confiné
à quatre fichiers `*_remote_data_source.dart` plus `AppConfig`.

**Négatives** — dépendance à un service tiers ; il faut réimplémenter à la
main ce que le SDK offre gratuitement (parsing des sessions, rotation des
tokens, gestion des erreurs GoTrue).

## Évolution

À revoir si le projet a besoin de logique serveur (paiement, envoi d'e-mails
transactionnels, agrégations lourdes). Les Edge Functions Supabase peuvent
alors être une étape intermédiaire avant un backend dédié.
