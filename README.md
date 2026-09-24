# Beesounours

Vous incarnez un ours qui n'hésite pas à malmener les animaux de la forêt pour récupérer du miel. Un jeu d'action 2D, développé avec Godot en équipe de 3 lors de la Game Jam 4, organisée à l'IUT de Reims.

## Équipe — La Bulle 2

- Tom Legros (Cryoro)
- Benjamin Pierret (Reshomy)
- Arthur Sauvaget (Boubou)

## Comment jouer

- Flèches : se déplacer
- Espace : frapper
- Maintenir Shift : courir
- A : rétrécir
- E : s'agrandir

Une barre d'endurance se régénère avec le temps, et une barre de vie se remplit en tuant des ennemis.

## Lancer le jeu

**Linux** : téléchargez `Beesounours.sh`, `Beesounours.x86_64` et `Beesounours.pck` (dans le même dossier), rendez le script exécutable si besoin, puis :

```bash
./Beesounours.sh
```

**Windows** : téléchargez `Beesounours.exe` et `Beesounours.pck` depuis `game/export_windows/` (dans le même dossier), puis lancez `Beesounours.exe`.

## Technique

- Moteur : [Godot](https://godotengine.org/)
- Le code source du projet se trouve dans le dossier `game/`

## Contenu du dépôt

```
├── README.md
├── metadata.yaml
├── artwork/                # affiche, miniature et vidéo de présentation du jeu
├── game/                   # code source du projet Godot
│   └── export_windows/     # build Windows (.exe + .pck)
├── Beesounours.sh          # script de lancement (Linux)
├── Beesounours.x86_64      # exécutable (Linux)
└── Beesounours.pck         # données du jeu (Linux)
```
