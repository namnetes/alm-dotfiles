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


## make mount command output pretty and human readable format
alias mount='mount | column -t'


## handy aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias f='free -t'
alias h='history | fzf'
alias j='jobs -l'
alias fdf='fdfind'
alias c='clear'
alias n='nano'   # Regardez ~/.nanorc !

## show open ports et l'IP de la machine
## '-t' affiche les connexions TCP
## '-u' affiche les connaxions UDP
## '-l' affiche uniquement les sockets d'écoute
## '-n' affiche les IP et les ports sous forme numérique
## '-p' affiche le nom du processus et son PID
alias p='ss -tulnp'
alias myip='show_ip'


## sourcer la configuration
alias src='source $HOME/.bashrc'


## xclip
alias xclip='xclip -selection clipboard'
alias wclip='wl-copy'


## display function defined in the custom .bash_functions
if [ -f "$HOME/.bash_functions" ]; then
  alias func="finfo $HOME/.bash_functions"
fi


## Update hostname
if [ -f "$HOME/.functions/update_hostname.sh" ]; then
  alias uh="sudo HOME=$HOME bash $HOME/.functions/update_hostname.sh"
fi


## Update system
if [ -f "$HOME/.functions/update_system.sh" ]; then
  alias u="$HOME/.functions/update_system.sh"
fi


## Extraction de la bande son au format mp3 d'une video mp4 ou webm
if [ -f "$HOME/.functions/vid2mp3.sh" ]; then
  alias vid2mp3="$HOME/.functions/vid2mp3.sh"
fi


