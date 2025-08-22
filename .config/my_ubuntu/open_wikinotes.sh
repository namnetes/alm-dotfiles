#!/usr/bin/bash

# Vérification et déplacement dans le répertoire
cd "$HOME/alm-technook" || { 
  notify-send "Erreur" "Le répertoire n'existe pas : $HOME/alm-technook" -u critical
  exit 1
}

# Mise à jour du dépôt Git
if ! git pull; then
  notify-send "Erreur" "Échec lors de la mise à jour du dépôt Git" -u critical
  exit 1
fi

# Ouverture du fichier HTML
if ! xdg-open "grimoire_moderne.html"; then
  notify-send "Erreur" "Échec lors de l'ouverture de grimoire_moderne.html" -u critical
  exit 1
else
  notify-send "Succès" "Le fichier grimoire_moderne.html a été ouvert avec succès"
fi
