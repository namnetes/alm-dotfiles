#!/usr/bin/env bash


############################################################################
## Jupyter Lab : Fonctions d'activation d'environnements                  #
############################################################################

# Pour activer un environnement Python
if command -v python3 &> /dev/null; then
  ve() {
    # Si le nombre d'arguments est égal à 0
    if [ $# -eq 0 ]; then
      if [ -d "./.venv" ]; then
        source ./.venv/bin/activate
      else
        echo "Aucun répertoire .venv trouvé ici dans $PWD !"
        return 1
      fi
    # Si le nombre d'arguments est supérieur à 0
    else
      cd "$1" || return 1
      source ".venv/bin/activate" || {
        echo "Aucun .venv trouvé dans $1 !"
        return 1
      }
    fi
  }
fi

if [ -n "${SANDBOX_HOME:-}" ]; then
  jl() {
    ve "$SANDBOX_HOME" || return 1
    jupyter lab
    deactivate
    cd "$HOME" || return # Retourner au répertoire personnel
  }

  ipy() {
    ve "$SANDBOX_HOME" || return 1
    ipython
    deactivate
    cd "$HOME" || return # Retourner au répertoire personnel
  }
fi


############################################################################
## FZF : fonction avancée                                                  #
############################################################################
if command -v fzf >/dev/null 2>&1; then

  # fkill : Recherche fuzzy et tue un processus par son PID
  unalias fkill 2>/dev/null
  unset -f fkill 2>/dev/null

  fkill() {
    local pid
    pid=$(ps aux | fzf --header="Sélectionner le processus à tuer" \
      --height 40% --layout=reverse | awk '{print $2}')
    [ -n "$pid" ] && kill "$pid" && echo "Processus $pid terminé."
  }

fi


###############################################################################
# Affiche les chemins de la variable PATH sous forme de liste numérotée       #
###############################################################################
path() { # Affiche une liste numérotée des chemins dans PATH
  echo "$PATH" | tr ':' '\n' | nl
}


###############################################################################
# Affiche les chemins de la variable LDPATH sous forme de liste numérotée     #
###############################################################################
ldpath() { # Affiche une liste numérotée des chemins dans LDPATH
  if [ -z "${LD_LIBRARY_PATH:-}" ]; then
    echo "LD_LIBRARY_PATH n'est pas défini."
    return 1
  fi
  echo "$LD_LIBRARY_PATH" | tr ':' '\n' | nl
}


###############################################################################
# Affiche une règle numérique alignée à la largeur du terminal                #
###############################################################################
rule() { # Affiche une règle alignée à la largeur du terminal
  if [ $# -eq 0 ]; then
    local offset=0  # Pas de paramètres, pas d'espace avant la règle
  else
    local offset=$1 # Le premier paramètre est le décalage en espaces
  fi

  # Déterminer la largeur du terminal
  local width
  width=$(tput cols)

  # Créer une chaîne remplie de '0' avec la longueur de la largeur du terminal
  local rule
  rule=$(printf "%*s" "$width" "" | tr ' ' '0')

  # Remplacer chaque 0 par la séquence 123456789
  rule=$(echo "$rule" | sed 's/0/123456789 /g')

  # Ajouter des espaces de décalage avant d'afficher la règle
  local spaces
  spaces=$(printf "%${offset}s" "")
  echo "${spaces}${rule:0:$((width - offset))}"
}

###############################################################################
# Affiche une règle puis exécute head avec les arguments donnés               #
###############################################################################
rh() { # Affiche une règle puis exécute head avec les arguments donnés

  # Appelle la fonction rule pour afficher la règle dynamique
  rule

  # Appelle la commande head avec tous les arguments fournis
  head "$@"
}


###############################################################################
# Idem rh mais affiche en plus la longueur de la ligne                        #
###############################################################################
rhc() { # Idem rh mais affiche en plus la longueur de la ligne
  # Appelle la fonction rule pour afficher la règle dynamique
  rule 5

  # Utilise head pour obtenir les n premières lignes
  local head_lines
  head_lines=$(head "$@")

  # Traite chaque ligne pour y ajouter sa longueur (toujours 4 caractères)
  while IFS= read -r line; do
    # Calcule la longueur de la ligne
    line_length=$(echo -n "$line" | wc -c)

    # Formate line_length sur 4 caractères avec des espaces de début
    line_length=$(printf "%4s" "$line_length")

    # Affiche la sortie formatée
    printf "%s %s\n" "$line_length" "$line"
  done <<<"$head_lines"
}


###############################################################################
# Idem rh mais avec tail pour traiter la fin du fichier                       #
###############################################################################
th() { # Idem rh mais avec tail pour traiter la fin du fichier
  # Appelle la fonction rule pour afficher la règle dynamique
  rule

  # Appelle la commande tail avec tous les arguments fournis
  tail "$@"
}


###############################################################################
# Affiche la dernière version disponible d'images Docker depuis Docker Hub    #
###############################################################################
dlvi() { # Affiche la dernière version disponible d'une image Docker
  # Vérifier si curl et jq sont installés
  if ! command -v curl &>/dev/null; then
    echo "Erreur : curl n'est pas installé."
    return 1
  fi

  if ! command -v jq &>/dev/null; then
    echo "Erreur : jq n'est pas installé."
    return 1
  fi

  # Vérifier que des noms d'images sont fournis
  if [ "$#" -eq 0 ]; then
    echo "Utilisation : dlvi <nom_image1> [<nom_image2> ...]"
    echo "Exemple : dlvi elasticsearch logstash kibana"
    return 1
  fi

  # Traiter chaque nom d'image fourni en argument
  for image in "$@"; do
    echo "Récupération de la dernière version de l'image Docker : $image"

    # Obtenir les tags pour l'image spécifiée depuis Docker Hub
    # -f : échoue sur les erreurs HTTP (4xx, 5xx) au lieu de retourner 0
    local url="https://registry.hub.docker.com/v2/repositories"
    response=$(curl -sf \
      "${url}/library/${image}/tags/?page_size=100")

    if [ $? -ne 0 ]; then
      echo "Échec de la récupération des tags pour l'image : $image"
      continue
    fi

    # Extraire et trier les tags
    tags=$(echo "$response" | jq -r '.results[].name' | sort -V)

    # Vérifiez si des tags ont été trouvés
    if [ -z "$tags" ]; then
      echo "Aucun tag trouvé pour l'image : $image"
      continue
    fi

    # Récupérer le dernier tag
    latest_version=$(echo "$tags" | tail -n 1)

    echo "La dernière version de $image est : $latest_version"
  done
}


###############################################################################
# Lance gnome-text-editor en arrière-plan avec les fichiers donnés            #
###############################################################################
ge() { # Lance gnome-text-editor en arrière-plan avec les fichiers donnés
  gnome-text-editor "$@" &
}


###############################################################################
# Vérifie l'état Git de plusieurs projets et affiche leur statut              #
###############################################################################
gsp() { # Affiche le statut de plusieurs projets Git
  # Sauvegarder le répertoire actuel
  local current_dir
  current_dir=$(pwd)

  # Définir les projets et leurs chemins
  local projects=(
    "$HOME/alm-dotfiles"
    "$HOME/alm-tools"
    "$HOME/alm-technook"
  )

  # Codes de couleur ANSI
  local GREEN="\e[32m"
  local RED="\e[31m"
  local RESET="\e[0m"

  # Icônes pour la police Firacode avec couleurs
  local icon_clean="${GREEN}✔${RESET}"    # Vert pour un dépôt propre
  local icon_dirty="${RED}✖${RESET}"      # Rouge pour un dépôt modifié

  # Fonction pour vérifier l'état de chaque projet
  local status
  for project in "${projects[@]}"; do
    if [ -d "$project/.git" ]; then
      cd "$project" || continue # Continuer en cas d'échec

      # git status --porcelain
      #  - affiche une sortie simplifiée adaptée aux scripts.
      # grep -qE '^[ MADRCU?]'
      #  - détecte les lignes indiquant des fichiers modifiés ou non suivis.
      if git status --porcelain | grep -qE '^[ MADRCU?]'; then
          status="$icon_dirty Modifié"
      else
          status="$icon_clean Propre"
      fi

      echo -e "$(basename "$project"):\t$status"
    else
      echo -e "$(basename "$project"):\t🚫 Pas un dépôt Git"
    fi
  done

  # Restaurer le répertoire original
  cd "$current_dir" || return # Restaurer le répertoire d'origine
}


###############################################################################
# Renommer en lot les fichiers image dans le répertoire courant.              #
###############################################################################
renimg() { # Renommer en lot les fichiers image
  python3 "$HOME/.functions/tools/rename_images.py" "$@"
}


###############################################################################
# Vérifie que chaque ligne du CSV a le même nombre de colonnes                #
###############################################################################
csvc() { # Vérifie que chaque ligne du CSV a le même nombre de colonnes
  python3 "$HOME/.functions/tools/check_csv.py" "$@"
}


###############################################################################
# Affiche la liste des fonctions du script dont le nom est passé en paramètre #
###############################################################################
finfo() { # Affiche la liste des fonctions du script passé en paramètre
  bash "$HOME/.functions/bin/list_functions.sh" "$@"
}


###############################################################################
# Affiche les interfaces réseau avec leurs adresses IPv4 et IPv6              #
###############################################################################
show_ip() { # Affiche les interfaces réseau avec leurs adresses IPv4 et IPv6
  echo "🔍 Interfaces avec IP détectées :"

  # Liste des interfaces avec IPv4
  ip -o -4 addr show | while read -r line; do
    iface=$(echo "$line" | awk '{print $2}')
    ipv4=$(echo "$line" | awk '{print $4}')
    echo "🖧 Interface: $iface"
    echo "   IPv4: $ipv4"
  done

  # Liste des interfaces avec IPv6 (scope global, exclut link-local fe80::)
  ip -o -6 addr show scope global | while read -r line; do
    iface=$(echo "$line" | awk '{print $2}')
    ipv6=$(echo "$line" | awk '{print $4}')
    echo "🖧 Interface: $iface"
    echo "   IPv6: $ipv6"
  done
}


###############################################################################
# Administration des VM KVM                                                   #
###############################################################################
kadm() { # Administration des VM KVM
  python3 "$HOME/.functions/tools/manage_kvm.py" "$@"
}


###############################################################################
# Assistant GnuPG - Chiffrer/Déchiffrer un fichier                            #
###############################################################################
gpgtool() { # Assistant GnuPG - Chiffrer/Déchiffrer un fichier
  python3 "$HOME/.functions/tools/encrypt_gpg.py"
}


###############################################################################
# Teste si une clé USB est bootable via QEMU                                  #
###############################################################################
usbboot() { # Teste si un périphérique USB est bootable avec QEMU
  if ! command -v qemu-system-x86_64 &>/dev/null; then
    echo "Erreur : qemu-system-x86_64 n'est pas installé."
    echo "Installez-le avec : sudo apt install qemu-system-x86"
    return 1
  fi

  if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
usbboot — teste si un périphérique USB est bootable via QEMU

UTILISATION
  usbboot <périphérique>

ARGUMENTS
  <périphérique>   Chemin du périphérique bloc (ex. /dev/sdb).
                   Les droits de lecture sont vérifiés ; si
                   nécessaire, sudo est invoqué automatiquement.

OPTIONS
  -h, --help       Affiche cette aide.

PRÉREQUIS
  qemu-system-x86_64   sudo apt install qemu-system-x86

EXEMPLES
  usbboot /dev/sdb        # clé USB sur /dev/sdb
  usbboot /dev/sdc        # clé USB sur /dev/sdc

NOTES
  - KVM est activé automatiquement si /dev/kvm est accessible
    (accélération matérielle).
  - Fermez la fenêtre QEMU pour arrêter le test.
  - Identifiez votre périphérique au préalable avec : lsblk
EOF
    [ "$#" -eq 0 ] && return 1 || return 0
  fi

  local device="$1"

  if [ ! -b "$device" ]; then
    echo "Erreur : '$device' n'est pas un périphérique bloc valide."
    return 1
  fi

  if [ ! -r "$device" ]; then
    echo "Droits insuffisants — relance en superutilisateur..."
    sudo bash -c \
      "$(declare -f usbboot); usbboot $(printf '%q' "$device")"
    return $?
  fi

  local qemu_args=(
    -m 1024
    -drive "file=$device,format=raw,if=virtio"
    -boot order=c
  )

  if [ -w /dev/kvm ]; then
    qemu_args+=(-enable-kvm)
  fi

  echo "Démarrage de '$device' dans QEMU..."
  echo "Fermez la fenêtre QEMU pour arrêter le test."
  qemu-system-x86_64 "${qemu_args[@]}"
}


###############################################################################
# Inventaire des shims et outils personnels installés                         #
###############################################################################
shims() { # Inventaire des shims — usage : shims [filtre]
    local registry="$HOME/.local/share/alm-tools/shims.tsv"
    local shim_dir="$HOME/.local/bin"
    local grn='\033[0;32m' red='\033[0;31m'
    local yel='\033[0;33m' cyn='\033[0;36m'
    local bld='\033[1m'    rst='\033[0m'
    local filter="${1:-}"

    printf "\n${bld}%-12s %-18s %-22s %-20s %s${rst}\n" \
        "ALIAS" "COMMANDE" "SCRIPT" "PROJET" "STATUT"
    printf '%.0s─' {1..82}; echo

    local count=0 missing=0
    if [[ -f "$registry" ]]; then
        while IFS='|' read -r al cmd scr proj desc; do
            [[ -z "$al" ]] && continue
            [[ -n "$filter" \
                && "$al$cmd$scr$proj$desc" != *"$filter"* ]] && continue
            local st sc
            if [[ -x "$shim_dir/$al" ]]; then
                st="✓ installé"; sc="$grn"
            else
                st="✗ manquant"; sc="$red"; (( missing++ ))
            fi
            printf "%-12s %-18s %-22s %-20s ${sc}%s${rst}\n" \
                "$al" "$cmd" "$scr" "$(basename "$proj")" "$st"
            (( count++ ))
        done < <(grep -v '^[[:space:]]*#' "$registry" \
                 | grep -v '^[[:space:]]*$')
    else
        printf "  Aucun registre trouvé : %s\n" "$registry"
    fi

    # Détection des fichiers exécutables non enregistrés dans ~/.local/bin
    if [[ -z "$filter" && -d "$shim_dir" ]]; then
        local orphans=()
        while IFS= read -r f; do
            local b; b=$(basename "$f")
            if ! grep -q "^${b}|" "$registry" 2>/dev/null \
               && file "$f" | grep -qiE 'text|script'; then
                orphans+=("$b")
            fi
        done < <(find "$shim_dir" -maxdepth 1 -type f -executable \
                 ! -name 'env' ! -name 'env.fish')
        if [[ ${#orphans[@]} -gt 0 ]]; then
            echo ""
            printf "${yel}Scripts non enregistrés :${rst} %s\n" \
                "${orphans[*]}"
            printf "  Enregistrez avec : shim_add <alias> <cmd>" \
                " <script> <projet> <desc>\n"
        fi
    fi

    echo ""
    printf "  ${cyn}%d outil(s)${rst}" "$count"
    [[ $missing -gt 0 ]] \
        && printf " · ${red}%d manquant(s)${rst}" "$missing"
    printf " · registre : %s\n\n" "$registry"
}


###############################################################################
# Ajoute un outil au registre des shims                                       #
###############################################################################
shim_add() { # Enregistre un shim : shim_add <alias> <cmd> <script> <proj> <desc>
    local registry="$HOME/.local/share/alm-tools/shims.tsv"

    if [[ $# -lt 5 ]]; then
        printf "Usage : shim_add <alias> <commande> <script>" \
            " <chemin_projet> <description>\n"
        return 1
    fi

    local al="$1" cmd="$2" scr="$3" proj="$4" desc="$5"

    mkdir -p "$(dirname "$registry")"

    if grep -q "^${al}|" "$registry" 2>/dev/null; then
        printf "[!] '%s' est déjà dans le registre.\n" "$al"
        return 1
    fi

    printf "%s|%s|%s|%s|%s\n" \
        "$al" "$cmd" "$scr" "$proj" "$desc" >> "$registry"
    printf "[✓] '%s' ajouté au registre.\n" "$al"
}


###############################################################################
## Réinitialisation de Zed                                                    #
###############################################################################
init_zed() { # Réinitialisation complète de Zed
  if command -v zed >/dev/null 2>&1; then
    "$HOME/.functions/bin/init_zed.sh"
  else
    echo "Zed n'est pas installé sur ce système."
  fi
}
