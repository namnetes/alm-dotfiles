#!/usr/bin/env bash

# Script : convert_audio.sh
# Description : Extrait la bande son d’un fichier .webm ou .mp4 et la convertit en .mp3
#               avec un bitrate adapté à la qualité d’origine.
# Usage : ./convert_audio.sh "fichier.webm" ou "fichier.mp4"

show_help() {
  echo "Usage : $0 <fichier.webm|fichier.mp4>"
  echo ""
  echo "Ce script extrait la bande son d’un fichier vidéo (.webm ou .mp4)"
  echo "et la convertit en fichier .mp3 avec un bitrate adapté à la qualité d’origine."
  echo ""
  echo "Options :"
  echo "  -h, --help     Affiche cette aide"
  exit 0
}

# Aide
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi

# Vérifie ffmpeg
if ! command -v ffmpeg &> /dev/null || ! command -v ffprobe &> /dev/null; then
  echo "Erreur : ffmpeg et/ou ffprobe ne sont pas installés."
  exit 1
fi

# Vérifie l’entrée
INPUT="$1"
if [ -z "$INPUT" ]; then
  echo "Erreur : aucun fichier fourni."
  echo "Utilisez -h pour l’aide."
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "Erreur : le fichier '$INPUT' n'existe pas."
  exit 1
fi

EXT="${INPUT##*.}"
if [[ "$EXT" != "webm" && "$EXT" != "mp4" ]]; then
  echo "Erreur : le fichier doit être au format .webm ou .mp4"
  exit 1
fi

# Fichier de sortie
OUTPUT="${INPUT%.*}.mp3"
if [ -f "$OUTPUT" ]; then
  echo "Le fichier '$OUTPUT' existe déjà. Conversion ignorée."
  exit 0
fi

# Détection du bitrate audio
BITRATE=$(ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$INPUT")

# Si non détecté, valeur par défaut
if [ -z "$BITRATE" ]; then
  BITRATE=192000
fi

# Arrondir à la valeur MP3 la plus proche (max 320k)
if [ "$BITRATE" -ge 256000 ]; then
  TARGET_BITRATE="320k"
elif [ "$BITRATE" -ge 192000 ]; then
  TARGET_BITRATE="256k"
elif [ "$BITRATE" -ge 128000 ]; then
  TARGET_BITRATE="192k"
else
  TARGET_BITRATE="128k"
fi

echo "Bitrate audio détecté : $((BITRATE / 1000)) kbps → conversion en MP3 à $TARGET_BITRATE"

# Conversion
ffmpeg -i "$INPUT" -vn -ar 44100 -ac 2 -b:a "$TARGET_BITRATE" "$OUTPUT"
echo "Conversion terminée : '$OUTPUT'"
