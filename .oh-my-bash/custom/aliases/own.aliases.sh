# Add your own custom alias in the custom/aliases directory. Aliases placed
# here will override ones with the same name in the main alias directory.
#
# Usage:
#
# 1. use the exact naming schema like '<my_aliases>.aliases.sh' where the
#    filename needs to end with .aliases.sh (just <my_aliases>.sh does not
#    work)
# 2. add the leading part of that filename ('<my_aliases>' in this example) to
#    the 'aliases' array in your ~/.bashrc

## fzf integration
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
  alias fnv="fzf --preview 'batcat --style=numbers --color=always {}' | xargs -n 1 nvim"
fi

## zoxide integration
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  alias cd='z'
fi

## dotfiles only
alias lh='shopt -s nullglob dotglob; hidden=(.[^.]*); \
[[ ${#hidden[@]} -gt 0 ]] && ls -dl .[^.]* || echo "No hidden file"'

## make mount command output pretty and human readable format
alias mount='mount | column -t'

## handy aliases
alias f='free -t'
alias h='history | fzf'
alias j='jobs -l'
alias fdf='fdfind'

## show open ports et l'IP de la machine
## '-t' affiche les connexions TCP
## '-u' affiche les connaxions UDP
## '-l' affiche uniquement les sockets d'écoute
## '-n' affiche les IP et les ports sous forme numérique
## '-p' affiche le nom du processus et son PID
alias p='ss -tulnp'
alias myip='show_ip'

## Quelques options au lancement de nano
## -l          : affiche les numéros de ligne
## -c          : affiche en continu le numéro de ligne, la colonne et diverses statistiques
## -i          : active l'indentation automatique
## -E          : remplace les tabulations par des espaces
## -W          : désactive le retour automatique à la ligne (line wrapping)
## --tabsize=3 : définit la taille des tabulations à 3 espaces
alias n='nano -lciEW --tabsize=2'

## update ubuntu system
alias u='sudo apt update && sudo apt upgrade && sudo snap refresh'

## xclip
alias xclip='xclip -selection clipboard'
alias wclip='wl-copy'


## display fucntion defined in the custom folder of .oh-my-bash
if [ -f "$HOME/.oh-my-bash/custom/functions/own.functions.sh" ]; then
  alias func="grep -E '^\s*[a-zA-Z0-9_]+\s*\(\)\s*\{' ~/.oh-my-bash/custom/functions/own.functions.sh | sed s'/{//g'"
fi

if [ -f "$HOME/alm-tools/kvm/vm-clone.sh" ]; then
  alias vclone='bash $HOME/alm-tools/kvm/vm-clone.sh'
fi

if [ -f "$HOME/alm-tools/kvm/vm-get-ip.sh" ]; then
  alias vip='bash $HOME/alm-tools/kvm/vm-get-ip.sh'
fi

if [ -f "$HOME/alm-tools/kvm/vm-list.sh" ]; then
  alias vlist='bash $HOME/alm-tools/kvm/vm-list.sh'
fi

if [ -f "$HOME/alm-tools/kvm/vm-set-hostname.sh" ]; then
  alias vhost='bash $HOME/alm-tools/kvm/vm-set-hostname.sh'
fi

if [ -f "$HOME/alm-tools/kvm/vm-update-sshconfig.sh" ]; then
  alias vssh='bash $HOME/alm-tools/kvm/vm-update-sshconfig.sh'
fi

