# Documentation des outils `.functions/tools`

Ce répertoire documente les quatre scripts Python disponibles dans
`.functions/tools/`. Ces outils sont conçus pour être appelés depuis
les fonctions shell définies dans `.bash_functions`.

---

## Vue d'ensemble

### check_csv.py — Vérificateur CSV

Vérifie que toutes les lignes d'un fichier CSV ont le même nombre
de colonnes. → [Documentation complète](check_csv.md)

### encrypt_gpg.py — Chiffrement GPG

Chiffre ou déchiffre un fichier via GPG avec un mot de passe.
→ [Documentation complète](encrypt_gpg.md)

### manage_kvm.py — Gestionnaire KVM

Interface texte interactive pour gérer les machines virtuelles KVM.
→ [Documentation complète](manage_kvm.md)

### rename_images.py — Renommage d'images

Renomme en lot des fichiers image avec un préfixe et un numéro.
→ [Documentation complète](rename_images.md)

---

## Architecture générale

```mermaid
flowchart TD
    A([Shell utilisateur\n.bash_functions]) -->|appel| B[check_csv.py]
    A -->|appel| C[encrypt_gpg.py]
    A -->|appel| D[manage_kvm.py]
    A -->|appel| E[rename_images.py]

    B -->|lit| F[(Fichier CSV)]
    C -->|lit / écrit| G[(Fichier .gpg)]
    D -->|commandes virsh| H[(KVM / libvirt)]
    E -->|renomme| I[(Fichiers image)]

    classDef startStop fill:#e1f5fe,stroke:#01579b
    classDef data fill:#fff3e0,stroke:#e65100
    classDef logic fill:#e8eaf6,stroke:#1a237e

    class A startStop
    class B,C,D,E logic
    class F,G,H,I data
```

---

## Comment ces outils sont-ils invoqués ?

Les fonctions dans `.bash_functions` servent de point d'entrée
depuis le terminal. Elles appellent les scripts Python avec les
bons arguments automatiquement.

```bash
# Vérifier un fichier CSV
check_csv mon_fichier.csv

# Renommer des images
rename_images vacances

# Chiffrer / déchiffrer un fichier
gpg_tool

# Gérer les VMs KVM
kvm_admin
```

> **Pour les débutants** : vous n'avez jamais à appeler les scripts
> Python directement. Les commandes courtes ci-dessus sont les seules
> que vous aurez à retenir.

---

## Prérequis communs

- **Python 3.10+** — requis par tous les scripts
- **`uv`** — gestionnaire de paquets Python du projet
  (utilisez `uv run <script>` pour exécuter un script)
- Dépendances spécifiques à chaque outil listées dans leur page
