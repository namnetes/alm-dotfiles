"""
Ce script Python est un outil d'automatisation pour les projets Git. 
Son objectif principal est de synchroniser le fichier .gitignore avec une liste de règles d'exclusion prédéfinies.

Comment ça fonctionne ?
-----------------------
1. Il vérifie si un fichier .gitignore existe déjà dans le répertoire actuel.
2. Si le fichier n'existe pas, il le crée.
3. Si le fichier existe, il parcourt chaque ligne pour vérifier si des entrées de sa liste de référence sont manquantes.
4. Il affiche un message pour indiquer si le fichier est complet ou s'il manque des entrées.

Utilité :
---------
Le fichier .gitignore est crucial pour un projet Git car il indique quels fichiers et dossiers ignorer. 
Cela empêche le suivi de fichiers inutiles (comme les caches, les dépendances ou les fichiers de log) 
par le système de contrôle de version. Ce script garantit que votre fichier .gitignore contient 
toujours les exclusions essentielles pour une variété de langages de programmation et d'outils, 
vous aidant à maintenir un historique Git propre et organisé.
"""
import os

GITIGNORE_SECTIONS = {
    "🌐 Fichiers communs": [
        "*.log", "*.tmp", "*.bak", "*~", ".DS_Store", "Thumbs.db", ".idea/", ".vscode/",
        ".env", ".env.*"
    ],
    "🐚 Bash": [
        "*.sh~", "*.swp", "*.swo", "bash_history", ".bash_profile", ".bashrc"
    ],
    "🐍 Python": [
        "__pycache__/", "*.py[cod]", "*.pyo", "*.pyd", "*.egg", "*.egg-info/", "dist/",
        "build/", "*.spec", "*.sqlite3", "*.db", "*.ipynb_checkpoints/", ".mypy_cache/",
        ".pytest_cache/", ".tox/", ".venv/", "venv/", "Pipfile.lock", "poetry.lock"
    ],
    "🧠 JavaScript / Node.js": [
        "node_modules/", "npm-debug.log*", "yarn-debug.log*", "yarn-error.log*",
        "pnpm-lock.yaml", "package-lock.json", "dist/", "coverage/", ".next/", "out/",
        ".cache/", ".eslintcache"
    ],
    "☕ Java": [
        "*.class", "*.jar", "*.war", "*.ear", "*.iml", "target/", "bin/", "build/",
        ".gradle/", ".settings/", ".project", ".classpath"
    ],
    "🧪 Tests & CI": [
        "coverage/", "test-results/", "junit.xml", "*.lcov", "*.coverage"
    ],
    "🔧 Outils & IDE": [
        "*.sublime-workspace", "*.sublime-project", "*.code-workspace", "*.tmproj",
        "*.komodoproject", "*.kate-swp", "*.goutputstream*", "*.directory",
    ],
    "📦 Dépendances et artefacts": [
        "*.lock", "*.tar.gz", "*.zip", "*.exe", "*.dll", "*.so", "*.dylib", "*.out",
        "*.o", "*.obj", "*.a", "*.lib"
    ]
}

# La liste de référence complète est reconstruite à partir du dictionnaire
GITIGNORE_REFERENCE = [item for sublist in GITIGNORE_SECTIONS.values() for item in sublist]

path = ".gitignore"

if not os.path.exists(path):
    print(f"[INFO] Fichier {path} absent. Création en cours...")
    with open(path, "w") as f:
        # Écrire les sections et leurs lignes avec un en-tête de commentaire
        for section, lines in GITIGNORE_SECTIONS.items():
            f.write(f"\n# {section}\n")
            f.write("\n".join(lines) + "\n")
    print(f"[SUCCESS] Fichier {path} créé avec {len(GITIGNORE_REFERENCE)} entrées.")
else:
    print(f"[INFO] Fichier {path} déjà présent. Vérification du contenu...")
    with open(path, "r") as f:
        existing_lines = set(line.strip() for line in f if line.strip() and not line.startswith('#'))

    missing = [line for line in GITIGNORE_REFERENCE if line not in existing_lines]

    if not missing:
        print("[OK] Le fichier .gitignore est complet.")
    else:
        print(f"[WARNING] {len(missing)} entrées manquantes dans .gitignore :")
        for line in missing:
            # Recherche de la section manquante
            section_found = "Section inconnue"
            for section, rules in GITIGNORE_SECTIONS.items():
                if line in rules:
                    section_found = section
                    break
            print(f"  - {line} (dans la section '{section_found}')")
