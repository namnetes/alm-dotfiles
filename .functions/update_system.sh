#!/usr/bin/env bash

echo "🔄 Mise à jour du système..."
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

echo "📦 Mise à jour des snaps..."
if ! sudo snap refresh; then
  echo "⚠️ Certaines applications Snap sont en cours d'exécution et n'ont pas pu être mises à jour."
  echo "👉 Fermez-les manuellement et relancez 'sudo snap refresh' si nécessaire."
fi

echo "✅ Mise à jour terminée !"
