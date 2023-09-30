#!/bin/bash

# Initialiser tous les sous-modules
git submodule init

# Mettre à jour tous les sous-modules
git submodule update --recursive --remote

git add .

# Facultatif : effectuer un commit pour enregistrer les mises à jour des sous-modules
git commit -m "chore(submodules): Updating submodules."

# Facultatif : pusher les modifications vers le dépôt parent
git push
