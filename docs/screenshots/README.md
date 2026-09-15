# Captures d'écran du README

Le README référence cinq fichiers, **qui ne sont pas encore présents dans ce
dossier**. Tant qu'ils manquent, GitHub affiche une image cassée.

| Fichier attendu | Écran |
|---|---|
| `login.png` | Connexion |
| `catalog.png` | Catalogue |
| `detail.png` | Détail d'un film |
| `favorites.png` | Favoris |
| `profile.png` | Profil (avec le sélecteur de langue) |

## Les produire

```bash
# 1. Lancer l'application sur un émulateur ou un appareil
flutter run --dart-define-from-file=env.json

# 2. Depuis un autre terminal, pour chaque écran affiché :
flutter screenshot --out=docs/screenshots/catalog.png
```

`flutter screenshot` capture l'appareil connecté ; sur un émulateur Android,
`adb exec-out screencap -p > docs/screenshots/catalog.png` fonctionne aussi.

## Recommandations

- **Une largeur homogène** (1080 px suffit) : le tableau du README met les
  cinq images côte à côte, des tailles différentes le déforment.
- **Compresser** avant de committer. Une capture PNG brute pèse souvent plus
  d'1 Mo ; `pngquant --quality=65-80` la ramène sous 200 Ko sans différence
  visible.
- **Aucune donnée réelle.** Utilisez le compte de démonstration créé par
  `supabase/seed.sql`, pas une adresse e-mail personnelle : ces images sont
  publiques.
- Pensez à faire une capture du profil **en anglais** si vous voulez montrer
  l'internationalisation.
