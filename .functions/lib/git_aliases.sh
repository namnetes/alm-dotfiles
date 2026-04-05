###############################################################################
# Script : load_git_aliases
# Auteur : Alan MARCHAND (keltalan@proton.me)
# Objectif :
#   Ce script lit la section [alias] du fichier ~/.gitconfig
#   et crée automatiquement des alias Bash correspondants.
#
#   Exemple :
#       Dans ~/.gitconfig :
#           [alias]
#               gst = status
#               gco = checkout
#
# Pourquoi faire cela ?
#   - Git permet de définir des alias internes mais utilisables 
#     uniquement avec le mot clé "git ...".
#     Mais ils ne sont pas reconnus directement comme commandes Bash.
#     Exemple : "git gst" fonctionne, mais pas "gst" tout seul.
#   - Ce script transforme les alias Git en alias Bash,
#     ce qui vous permet de taper directement la commande courte.
#
# Comment ça marche ?
#   1. Le script ouvre le fichier ~/.gitconfig
#   2. Il repère la section [alias]
#   3. Pour chaque ligne de cette section :
#        - Il récupère le nom de l’alias (ex: gst)
#        - Il récupère la commande associée (ex: status)
#        - Si la commande commence par "!", c’est une commande shell brute
#          → on la garde telle quelle
#        - Sinon, on la préfixe par "git " pour en faire une commande Git complète
#   4. Il crée un alias Bash avec la commande `alias nom="commande"`
#
# Comment l’exécuter ?
#   - Méthode ponctuelle :
#       Dans le terminal, tapez :
#           source /chemin/vers/git_aliases.sh
#       → Les alias seront disponibles immédiatement dans ce terminal.
#
#   - Méthode permanente :
#       1. Copiez la fonction et l’appel `load_git_aliases` dans le ~/.bashrc
#       2. Rechargez le shell :
#           source ~/.bashrc
#       3. Les alias seront automatiquement recréés à chaque ouverture de terminal.
#
# Remarques importantes :
#   - Si vous exécutez le script avec `./git_aliases.sh`, il sera lancé dans un
#     sous-shell et les alias disparaîtront à la fin. Il faut donc le SOURCER.
#   - Ce script ne modifie pas le ~/.gitconfig, il ne fait que le lire.
#   - Si vous avez un fichier ~/.gitconfig.local inclus via [include],
#     cette version ne le lit pas encore (mais on peut l’ajouter).
###############################################################################

# Fonction pour charger les alias Git comme alias Bash
load_git_aliases() {
    local gitconfig="$HOME/.gitconfig"
    local in_alias_section=0

    while IFS= read -r line; do
        # Détecter le début de la section [alias]
        if [[ $line =~ ^\[alias\] ]]; then
            in_alias_section=1
            continue
        fi

        # Si on arrive à une autre section, on sort
        if [[ $in_alias_section -eq 1 && $line =~ ^\[.*\] ]]; then
            break
        fi

        # Si on est dans la section alias et que la ligne n'est pas vide ou un commentaire
        if [[ $in_alias_section -eq 1 && $line =~ ^[[:space:]]*[^#[:space:]] ]]; then
            # Extraire nom et commande
            local name cmd
            name=$(echo "$line" | sed -E 's/^[[:space:]]*([^=[:space:]]+)[[:space:]]*=.*/\1/')
            cmd=$(echo "$line" | sed -E 's/^[[:space:]]*[^=]+=[[:space:]]*//')

            # Si la commande commence par "!", on retire le "!" et on garde tel quel
            if [[ $cmd =~ ^! ]]; then
                cmd="${cmd:1}"
            else
                cmd="git $cmd"
            fi

            # Déclarer l'alias bash
            alias "$name"="$cmd"
        fi
    done < "$gitconfig"
}
