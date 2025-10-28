# Fonction pour nettoyer et réorganiser la variable PATH
clean_path() {
    # Initialise une nouvelle variable PATH vide
    local new_path=""

    # Initialise une liste des chemins déjà ajoutés
    local seen_paths=""

    # Définis les chemins prioritaires dans l'ordre souhaité
    local target_order=("/home/galan/.local/bin" "/snap/bin")

    # Ajoute les chemins prioritaires s'ils sont présents et non encore ajoutés
    for p in "${target_order[@]}"; do
        if [[ ":$PATH:" == *":$p:"* && ":$seen_paths:" != *":$p:"* ]]; then
            new_path+="$p:"
            seen_paths+="$p:"
        fi
    done

    # Découpe le PATH original en tableau, séparé par les deux-points
    IFS=':' read -ra path_array <<< "$PATH"

    # Parcourt chaque chemin du PATH original
    for p in "${path_array[@]}"; do
        # Ajoute le chemin s'il n'a pas déjà été ajouté
        if [[ ":$seen_paths:" != *":$p:"* ]]; then
            new_path+="$p:"
            seen_paths+="$p:"
        fi
    done

    # Supprime le dernier deux-points inutile et exporte le nouveau PATH
    export PATH="${new_path%:}"
}

