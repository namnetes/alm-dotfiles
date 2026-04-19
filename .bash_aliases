#!/usr/bin/env bash
# ~/.bash_aliases
# Aliases personnalisés chargés depuis ~/.bashrc


## make mount command output pretty and human readable format
alias mount='mount | column -t'


## handy aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias f='free -t'
alias j='jobs -l'
alias fdf='fdfind'
alias c='clear'
alias n='nano'   # Regardez ~/.nanorc !

## history fuzzy search (dépend de fzf)
if command -v fzf &> /dev/null; then
  alias h='history | fzf'
fi


## show open ports et l'IP de la machine
## '-t' affiche les connexions TCP
## '-u' affiche les connexions UDP
## '-l' affiche uniquement les sockets d'écoute
## '-n' affiche les IP et les ports sous forme numérique
## '-p' affiche le nom du processus et son PID
alias p='ss -tulnp'

## show_ip est définie dans ~/.bash_functions
alias myip='show_ip'


## sourcer la configuration
alias src='source "$HOME/.bashrc"'


## xclip pour X11 et wl-copy pour Wayland
alias xclip='xclip -selection clipboard'
alias wclip='wl-copy'


## Affiche les fonctions définies dans ~/.bash_functions
if [ -f "$HOME/.bash_functions" ]; then
  alias func="finfo $HOME/.bash_functions"
fi


## Update hostname
if [ -f "$HOME/.functions/bin/update_hostname.sh" ]; then
  alias uh="sudo HOME=$HOME bash $HOME/.functions/bin/update_hostname.sh"
fi


## Update system
if [ -f "$HOME/.functions/bin/update_system.sh" ]; then
  alias u="$HOME/.functions/bin/update_system.sh"
fi


## Extraction de la bande son au format mp3 d'une video mp4 ou webm
if [ -f "$HOME/.functions/bin/vid2mp3.sh" ]; then
  alias vid2mp3="$HOME/.functions/bin/vid2mp3.sh"
fi


## Remplacer cat par bat s'il est installé
# --paging=never :
#   Désactive l'utilisation du 'pager' (comme 'less') qui est
#   utilisé par défaut par 'bat' pour les longs fichiers.
#   Ceci assure que 'bat' se comporte comme 'cat' en affichant
#   tout le contenu sans pause (défilement).
#
# --style=plain :
#   Supprime les éléments d'affichage décoratifs de 'bat',
#   tels que la bordure et l'en-tête contenant le nom du fichier.
#   Ceci rend la sortie plus minimaliste, se rapprochant de 'cat'
#   tout en conservant la coloration syntaxique.
if command -v bat &> /dev/null; then
  alias cat='bat --paging=never --style=plain'
fi


## Inventaire des shims et outils personnels (tl = tools list)
alias tl='shims'


## Claude Code — initialise le CLAUDE.md dans le projet courant
## Templates stockés dans ~/.claude/ et gérés via alm-dotfiles (Stow)
alias claude-open='\
  cp ~/.claude/CLAUDE_Open.md ./CLAUDE.md && \
  echo "CLAUDE.md (Développement Open) initialized in $(pwd)"'

alias claude-z='\
  cp ~/.claude/CLAUDE_Mainframe.md ./CLAUDE.md && \
  echo "CLAUDE.md (Technologies Mainframe) initialized in $(pwd)"'
