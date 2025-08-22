# Pourquoi on commence par supprimer /snap/bin du PATH ?
# ------------------------------------------------------
# Le système ajoute automatiquement /snap/bin à la fin du PATH via :
#   /etc/profile.d/apps-bin-path.sh
#
# Ce script vérifie si /snap/bin est présent dans le PATH, mais seulement à la
# fin. Il ne détecte pas si /snap/bin est déjà ailleurs, comme en tête du PATH.
#
# Résultat : on peut se retrouver avec plusieurs /snap/bin dans le PATH.
# Cela peut provoquer des conflits ou des comportements imprévisibles.
#
# 👉 Pour éviter cela, on supprime toutes les occurrences de /snap/bin,
# puis on le réinsère proprement en tête du PATH.
#
# l'objectif ici est aussi de donner la priorité aux binaires Snap sur ceux
# installés via APT.

# Supprimer toutes les occurrences de /snap/bin
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '^/snap/bin$' | paste -sd: -)

# Ajouter /snap/bin en tête
export PATH="/snap/bin:$PATH"
