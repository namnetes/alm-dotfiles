#!/usr/bin/env bash


############################################################################
## Starship Shell                                                          #
############################################################################
STARSHIP_VERSION=$(starship --version 2>/dev/null | head -n 1)

if [[ "$STARSHIP_VERSION" =~ ^starship\ [0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  eval "$(starship init bash)"
fi


############################################################################
## Jupyter Lab : Environnement bac à sable                                 #
############################################################################
JUPYTER_DIR="$HOME/Workspace/sandbox"

# Python3 est installé
if command -v python3 &> /dev/null; then
  # Pour activer un environnement Python
  function ve() {
    # Si le nombre d'arguments est égal à 0
    if [ $# -eq 0 ]; then
      if [ -d "./.venv" ]; then
        source ./.venv/bin/activate
      else
        echo "Aucun répertoire .venv trouvé ici dans $PWD !"
      fi
    # Si le nombre d'arguments est supérieur à 0
    else
      cd "$1" || return # Changer de répertoire et retourner en cas d'échec
      source "$1/.venv/bin/activate"
    fi
  }
fi

if [ -d "$JUPYTER_DIR" ]; then
  export SANDBOX_HOME="$JUPYTER_DIR"
  if grep -qE "(Microsoft|WSL)" /proc/version; then
    export BROWSER="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
  fi

  function jl() {
    ve "$SANDBOX_HOME"
    jupyter lab
    deactivate
    cd "$HOME" || return # Retourner au répertoire personnel et retourner en cas d'échec
  }

  function ipy() {
    ve "$SANDBOX_HOME"
    ipython
    deactivate
    cd "$HOME" || return # Retourner au répertoire personnel et retourner en cas d'échec
  }
fi


############################################################################
## NodeJS                                                                 #
############################################################################
# Définit le répertoire où NVM (Node Version Manager) sera installé
export NVM_DIR="$HOME/.nvm"

# Vérifie si le script nvm.sh existe dans le répertoire NVM_DIR
# S'il existe, le charge (ceci charge NVM)
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"

  # Vérifie si le script de complétion bash pour NVM existe dans le répertoire NVM_DIR
  # S'il existe, le charge (ceci charge la complétion bash de NVM)
  if [ -s "$NVM_DIR/bash_completion" ]; then
    source "$NVM_DIR/bash_completion"
  fi
fi


############################################################################
## Configuration de Helix Editor                                           #
############################################################################
if command -v hx >/dev/null 2>&1; then
  export EDITOR="hx"
  export VISUAL="hx"
  alias helix='hx'
  if ! git config --get core.editor | grep -q "hx"; then
    git config --global core.editor "hx"
  fi
fi


############################################################################
## Configuration de Bat                                                    #
##                                                                         #
## Vérifie si 'bat' est disponible, sinon crée un alias vers 'batcat'      #
## Pourquoi ? Sur Debian/Ubuntu, le binaire s'appelle 'batcat' au lieu de  #
## 'bat'. Or, de nombreux outils comme fzf attendent le nom 'bat' pour     #
## fonctionner                                                             #
##                                                                         #
## À propos de 'bat' :                                                     #
## - C'est une version améliorée de 'cat'                                  #
## - Il affiche les fichiers avec :                                        #
##   • Syntax highlighting (couleurs selon le langage)                     #
##   • Numérotation des lignes                                             #
##   • Intégration Git (affiche les changements)                           #
##   • Pagination automatique                                              #
##   • Affichage des caractères spéciaux (option -A)                       #
## - Très utile comme previewer dans fzf                                   #
############################################################################
if ! command -v bat >/dev/null 2>&1; then
  # Vérifie si 'batcat' est installé
  if command -v batcat >/dev/null 2>&1; then
    # Crée le dossier ~/.local/bin s'il n'existe pas
    mkdir -p ~/.local/bin

    # Crée le lien symbolique uniquement s'il est absent
    if [ ! -e "$HOME/.local/bin/bat" ]; then
      ln -s "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi

    # Ajoute ~/.local/bin au PATH si ce n’est pas déjà présent
    case ":$PATH:" in
      *":$HOME/.local/bin:"*) ;;  # déjà présent, ne rien faire
      *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
  fi
fi


############################################################################
## Configuration FZF : fuzzy finder intelligent                           #
############################################################################
if command -v zoxide >/dev/null 2>&1; then

  # Charger les options par défaut depuis .fzfrc
  export FZF_DEFAULT_OPTS="$(cat ~/.fzfrc)"

  # Activer les raccourcis clavier et l'autocomplétion
  if [ -f /usr/share/fzf/key-bindings.bash ]; then
    source /usr/share/fzf/key-bindings.bash
  fi

  if [ -f /usr/share/fzf/completion.bash ]; then
    source /usr/share/fzf/completion.bash
  fi

  # Alias utiles pour booster la navigation
  # ---------------------------------------

  # Recherche rapide dans le dossier courant
  alias ff='fzf'

  # Recherche dans l’historique des commandes
  alias fh='history | fzf'

  # Navigation dans les dossiers
  alias fcd='cd $(find . -type d | fzf)'

  # Kill interactif
  alias fkill='ps aux | fzf | awk '\''{print $2}'\'' | xargs kill -9'

  # Recherche fuzzy avec preview via bat + ripgrep + fzf
  # En amon la compatibilité bat/batcat a déjà été vérifiée !
  if command -v rg >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    alias fsearch="rg --files | \
    fzf --preview 'bat --style=numbers --color=always {}'"
  fi

fi


############################################################################
# Intégration de ripgrep (rg) : recherche rapide et précise
############################################################################
if command -v rg &>/dev/null; then

  # Recherche simple dans tous les fichiers du dossier courant
  alias rgf='rg --smart-case --hidden --follow'

  # Recherche dans les fichiers visibles uniquement (ignore les dotfiles)
  alias rgv='rg --smart-case'

  # Recherche dans les fichiers cachés uniquement (dotfiles)
  alias rgdot='rg --smart-case --hidden --glob ".*"'

  # Recherche avec 3 lignes de contexte avant/après chaque correspondance
  alias rgc='rg --smart-case -C 3'

  # Recherche dans les fichiers d’un type donné (ex: js, py, md)
  alias rgt='rg --smart-case --type'

  # Recherche en excluant les dossiers de test ou build
  alias rgx='rg --smart-case --glob "!{tests,build}/*"'

  # Recherche dans les fichiers suivis par Git uniquement
  alias rggit='rg --smart-case --files | xargs rg'
fi


############################################################################
## Configuration de XOZIDE                                                 #
############################################################################
if command -v zoxide >/dev/null 2>&1; then

  # Active l'affichage du chemin final après l'exécution d'une commande 'z'
  # Par défaut, 'z' te redirige silencieusement vers un dossier.
  # Avec _ZO_ECHO=1, le chemin est affiché dans le terminal, ce qui est
  #  utile pour :
  # - comprendre où tu as été redirigée
  # - déboguer des scripts
  # - garder une trace visuelle de tes déplacements
  ########### export _ZO_ECHO=1

  # Indique à zoxide de résoudre les liens symboliques vers leur chemin réel
  # Cela permet d'éviter que zoxide enregistre plusieurs chemins différents
  # qui pointent en réalité vers le même dossier.
  # Utile si tu utilises des alias de dossiers, des montages ou des
  # raccourcis.
  # Exemple : /dev/latest → /dev/projets/v2025
  # Avec cette option, zoxide enregistrera /dev/projets/v2025 au lieu
  # de /dev/latest
  export _ZO_RESOLVE_SYMLINKS=1

  # Permet à Zoxide de s’initialiser à chaque ouverture de terminal et en
  # même temps de remplacer la commande traditionnelle 'cd' par 'z'
  eval "$(zoxide init --cmd cd bash)"

fi


############################################################################
# Intégration de eza (alternative moderne à ls)
############################################################################
if command -v eza &>/dev/null; then

  # Remplace la commande ls classique avec tri des dossiers en premier
  alias ls='eza --group-directories-first --color=auto'

  # Liste détaillée avec infos Git et tri des dossiers en premier
  alias ll='eza -l --group-directories-first --git'

  # Liste tous les fichiers, y compris les cachés, avec infos Git
  alias la='eza -la --group-directories-first --git'
  alias l='la'

  # Affiche l’arborescence du dossier courant jusqu’à 2 niveaux
  alias lt='eza --tree --level=2 --group-directories-first'

  # Trie les fichiers par taille décroissante
  alias lS='eza -l --sort=size'

  # Trie les fichiers par date de modification
  alias lD='eza -l --sort=date'

  # Trie les fichiers par extension (utile pour les projets multi-langages)
  alias lx='eza -l --sort=extension'

  # Affiche un fichier par ligne, sans détails
  alias l1='eza -1'

  # Affiche uniquement les répertoires du dossier courant
  alias ldir='eza -la --only-dirs'

  # Affiche uniquement les fichiers cachés (dotfiles), sans les dossiers
  alias lh="eza -la --only-files | grep '^\.'"
fi


############################################################################
## Configuration de Neovim                                                #
############################################################################
# Définit le répertoire d'installation potentiel de Neovim
export NVIM_HOME=/usr/local/nvim

# Vérifie si le répertoire des binaires de Neovim existe
if [ -d "$NVIM_HOME/bin" ]; then
  # S'il existe, l'ajoute au PATH et définit Neovim comme éditeur par défaut
  PATH="$NVIM_HOME/bin:$PATH"
  export EDITOR=nvim
else
  # Sinon, définit nano comme éditeur par défaut
  export EDITOR=nano
fi


############################################################################
## Gestionnaire de paquets Python UV                                      #
############################################################################
# Récupère la version de UV, supprime les erreurs et ne prend que le dernier champ (le numéro de version)
UV_VERSION=$("$HOME/.local/bin/uv" --version 2>/dev/null | awk '{print $NF}')

# Vérifie si UV_VERSION n'est pas vide, indiquant que UV est probablement installé
if [[ -n "$UV_VERSION" ]]; then
  # Si UV est installé, source son script d'environnement
  source "$HOME/.local/bin/env"
fi


############################################################################
## Configuration de Groovy + SDKMAN                                       #
############################################################################
export SDKMAN_DIR="$HOME/.sdkman"

# Vérifie si le script sdkman-init.sh existe dans le répertoire SDKMAN_DIR/bin
# S'il existe, le source (ceci initialise SDKMAN)
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

export GTK_MODULES=canberra-gtk-module


###############################################################################
# Affiche les chemins de la variable PATH sous forme de liste numérotée       #
###############################################################################
function path() { # Affiche une liste numérotée des chemins dans PATH
  echo "$PATH" | tr ':' '\n' | nl
}


###############################################################################
# Affiche les chemins de la variable LDPATH sous forme de liste numérotée     #
###############################################################################
function ldpath() { # Affiche une liste numérotée des chemins dans LDPATH
  echo "$LD_LIBRARY_PATH" | tr ':' '\n' | nl
}


###############################################################################
# Affiche une règle numérique alignée à la largeur du terminal                #
###############################################################################
function rule() { # Affiche une règle alignée à la largeur du terminal
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
function rh() { # Affiche une règle puis exécute head avec les arguments donnés

  # Appelle la fonction rule pour afficher la règle dynamique
  rule

  # Appelle la commande head avec tous les arguments fournis
  head "$@"
}


###############################################################################
# Idem rh mais affiche en plus la longueur de la ligne                        #
###############################################################################
function rhc() { # Idem rh mais affiche en plus la longueur de la ligne
  # Appelle la fonction rule pour afficher la règle dynamique
  rule 5

  # Utilise head pour obtenir les n premières lignes
  head_lines=$(head "$@")

  # Traite chaque ligne pour y ajouter sa longueur (toujours 4 caractères)
  while IFS= read -r line; do
    # Calcule la longueur de la ligne
    line_length=$(echo -n "$line" | wc -c)

    # Formate line_length pour toujours avoir 4 caractères avec des espaces de début
    line_length=$(printf "%4s" "$line_length")

    # Affiche la sortie formatée
    printf "%s %s\n" "$line_length" "$line"
  done <<<"$head_lines"
}


###############################################################################
# Idem rh mais avec tail pour traiter la fin du fichier                       #
###############################################################################
function th() { # Idem rh mais avec tail pour traiter la fin du fichier
  # Appelle la fonction rule pour afficher la règle dynamique
  rule

  # Appelle la commande tail avec tous les arguments fournis
  tail "$@"
}


###############################################################################
# Affiche la dernière version disponible d’images Docker depuis Docker Hub    #
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
    response=$(curl -s "https://registry.hub.docker.com/v2/repositories/library/${image}/tags/?page_size=100")

    # Vérifiez si la requête a réussi
    if [ "$?" -ne 0 ]; then
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
# Vérifie l’état Git de plusieurs projets et affiche leur statut              #
###############################################################################
gsp() { # Affiche le statut de plusieurs projets Git
  # Sauvegarder le répertoire actuel
  local current_dir="$(pwd)"

  # Définir les projets et leurs chemins
  projects=(
    "$HOME/alm-dotfiles"
    "$HOME/alm-tools"
    "$HOME/alm-technook"
  )

  # Codes de couleur ANSI
  GREEN="\e[32m"
  RED="\e[31m"
  BLUE="\e[34m"
  RESET="\e[0m"

  # Icônes pour la police Firacode avec couleurs
  icon_clean="${GREEN}✔${RESET}"    # Vert pour un dépôt propre
  icon_dirty="${RED}✖${RESET}"      # Rouge pour un dépôt modifié
  icon_not_git="${BLUE}🚫${RESET}"  # Bleu pour un dépôt non-Git

  # Fonction pour vérifier l'état de chaque projet
  for project in "${projects[@]}"; do
    if [ -d "$project/.git" ]; then
      cd "$project" || continue # Changer de répertoire et continuer en cas d'échec

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
  cd "$current_dir" || return # Restaurer le répertoire et retourner en cas d'échec
}


###############################################################################
# Renommer en lot les fichiers image dans le répertoire courant.              #
###############################################################################
renimg() { # Renommer en lot les fichiers image
  python3 "$HOME/.functions/rename_images.py" "$@"
}


###############################################################################
# Vérifie que chaque ligne du CSV a le même nombre de colonnes                #
###############################################################################
csvc() { # Vérifie que chaque ligne du CSV a le même nombre de colonnes
  python3 "$HOME/.functions/csv_checker.py" "$@"
}


###############################################################################
# Affiche la liste des fonctions du script dont le nom est passé en paramètre #
###############################################################################
finfo() { # Affiche la liste des fonctions du script passé en paramètre
  python3 "$HOME/.functions/functions_infos.py" "$@"
}


###############################################################################
# Synchronisation .gitignore du répertoire courant                            #
###############################################################################
gnore() { # Synchronisation .gitignore du répertoire courant
  python3 "$HOME/.functions/git_ignore.py"
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

  # Liste des interfaces avec IPv6
  ip -o -6 addr show | while read -r line; do
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
  python3 "$HOME/.functions/kvm_admin.py" "$@"
}


###############################################################################
# Assistant GnuPG - Chiffrer/Déchiffrer un fichier                            #
###############################################################################
gpgtool() { # Assistant GnuPG - Chiffrer/Déchiffrer un fichier
  python3 "$HOME/.functions/gpg_tool.py"
}


###############################################################################
# Génère dynamiquement les alias git depuis le .gitconfig                     #
###############################################################################
if [ -f "$HOME/.gitconfig" ] && [ -f "$HOME/.functions/git_aliases.sh" ]; then
  source "$HOME/.functions/git_aliases.sh"
  load_git_aliases
fi


###############################################################################
## Nettoyage et réorganisation de la variable PATH                            #
###############################################################################
if [ -f "$HOME/.functions/clean_path.sh" ]; then
  source "$HOME/.functions/clean_path.sh"
  clean_path
fi

