"""
rename_images.py
================
Utilitaire de renommage en lot de fichiers image.

Renomme tous les fichiers image du dossier courant selon le format :
    <préfixe>_<numéro>.<extension>

Exemples de résultat :
    vacances_01.jpg
    vacances_02.png
    vacances_03.webp

Usage :
    python rename_images.py <préfixe> [--dry-run]

Arguments :
    préfixe     Texte placé avant le numéro dans le nouveau nom.
    --dry-run   Affiche les renommages prévus SANS les effectuer.
                Utile pour vérifier avant de modifier quoi que ce soit.
"""

import os
import re
import argparse


def _natural_key(filename: str) -> list:
    """Génère une clé de tri "naturelle" pour un nom de fichier.

    Le tri alphabétique classique place "img10" avant "img2" car '1' < '2'.
    Ce tri naturel détecte les nombres dans le nom et les compare
    en tant qu'entiers, ce qui donne l'ordre attendu : img2, img10.

    Fonctionnement :
        re.split(r'(\\d+)', "img10.jpg")
        → ["img", "10", ".jpg"]        ← les nombres sont isolés
        Chaque partie est convertie en int si c'est un nombre,
        sinon mise en minuscule pour une comparaison insensible à la casse.

    Args:
        filename: Nom du fichier à trier.

    Returns:
        Liste de chaînes et d'entiers utilisée comme clé de comparaison.

    Exemple :
        sorted(["img10.jpg", "img2.jpg"], key=_natural_key)
        → ["img2.jpg", "img10.jpg"]
    """
    return [
        int(part) if part.isdigit() else part.lower()
        for part in re.split(r'(\d+)', filename)
    ]


def renommer_images(prefix: str, dry_run: bool = False) -> None:
    """Renomme en lot tous les fichiers image du dossier courant.

    Étapes réalisées :
        1. Nettoyage du préfixe (suppression des tirets/underscores en fin).
        2. Recherche de tous les fichiers image dans le dossier courant.
        3. Tri naturel des fichiers trouvés (img2 avant img10).
        4. Renommage au format <préfixe>_<numéro>.<extension>,
           avec un numéro à largeur fixe (01, 02... ou 001, 002...).

    Le padding (nombre de chiffres) est calculé automatiquement :
        - 9 fichiers ou moins  → 1 chiffre  (préfixe_1, préfixe_9)
        - 10 à 99 fichiers     → 2 chiffres (préfixe_01, préfixe_99)
        - 100 à 999 fichiers   → 3 chiffres (préfixe_001, préfixe_999)

    Si un fichier cible existe déjà, il est sauté avec un avertissement
    pour éviter d'écraser un fichier existant.

    Args:
        prefix:  Préfixe utilisé pour construire les nouveaux noms.
                 Les caractères `-`, `_` et `.` en fin de chaîne
                 sont supprimés automatiquement pour éviter les doublons
                 comme "vacances__01.jpg".
        dry_run: Si True, affiche uniquement ce qui serait fait,
                 sans modifier aucun fichier sur le disque.

    Exemple :
        renommer_images("vacances")
        # photo1.jpg  → vacances_01.jpg
        # image_2.png → vacances_02.png

        renommer_images("voyage", dry_run=True)
        # [dry-run] DSC001.jpg -> voyage_01.jpg   ← rien n'est modifié
    """
    # --- Nettoyage du préfixe ---
    # Supprime les caractères de séparation en fin de préfixe.
    # Exemple : "vacances_" devient "vacances", "trip-" devient "trip".
    prefix = re.sub(r'[-_.]$', '', prefix)

    # --- Extensions d'images supportées ---
    # On utilise un ensemble (set) plutôt qu'une liste pour des recherches
    # plus rapides (vérification en O(1) au lieu de O(n)).
    extensions = {
        "bmp", "gif", "jpeg", "jpg", "mp4",
        "png", "tif", "tiff", "webm", "webp"
    }

    # --- Sélection des fichiers image du dossier courant ---
    # os.listdir('.') retourne tous les fichiers et dossiers présents ici.
    # On filtre pour ne garder que les fichiers image valides.
    files = [
        f for f in os.listdir('.')
        if (
            # On ne traite que les fichiers (pas les sous-dossiers)
            os.path.isfile(f)
            # On ignore les fichiers cachés (commençant par un point)
            and not f.startswith('.')
            # On vérifie que l'extension est dans notre liste de formats
            # os.path.splitext("photo.jpg") → ("photo", ".jpg")
            # .lstrip('.') retire le point pour obtenir "jpg"
            and os.path.splitext(f)[1].lstrip('.').lower() in extensions
            # On ignore ce script lui-même s'il se trouve dans le dossier
            and f != os.path.basename(__file__)
        )
    ]

    # --- Cas où aucun fichier n'est trouvé ---
    total = len(files)
    if total == 0:
        print("Aucun fichier image trouvé dans le dossier courant.")
        return

    # --- Calcul du padding (nombre de chiffres dans la numérotation) ---
    # len(str(42)) → 2, donc les numéros seront sur 2 chiffres : 01, 02...
    # len(str(150)) → 3, donc les numéros seront sur 3 chiffres : 001, 002...
    digits = len(str(total))

    # Message informatif en mode dry-run
    if dry_run:
        print("Mode dry-run — aucun fichier ne sera modifié.\n")

    # --- Renommage de chaque fichier ---
    # sorted(..., key=_natural_key) trie dans l'ordre naturel attendu.
    # enumerate(..., start=1) fournit un compteur démarrant à 1.
    for i, file in enumerate(sorted(files, key=_natural_key), start=1):

        # Extraction de l'extension via os.path.splitext (méthode robuste)
        # Exemple : "photo.backup.jpg" → ("photo.backup", ".jpg")
        _, raw_ext = os.path.splitext(file)
        ext = raw_ext.lstrip('.')  # Retire le point : ".jpg" → "jpg"

        # Construction du nouveau nom
        # str(i).zfill(digits) : remplit de zéros à gauche
        # Exemple avec digits=2 : str(3).zfill(2) → "03"
        newname = f"{prefix}_{str(i).zfill(digits)}.{ext}"

        # --- Vérification : le fichier cible existe-t-il déjà ? ---
        # On ne renomme pas si le nom cible est déjà pris, pour éviter
        # d'écraser un fichier existant.
        if os.path.exists(newname):
            print(f"Attention: {newname} existe déjà, saut du fichier {file}")
            continue

        # --- Affichage ou renommage effectif ---
        if dry_run:
            # En mode dry-run, on affiche juste ce qui serait fait
            print(f"[dry-run] {file} -> {newname}")
        else:
            try:
                # Renommage réel du fichier sur le disque
                os.rename(file, newname)
                print(f"{file} -> {newname}")
            except OSError as e:
                # OSError couvre les erreurs de permission, fichier verrouillé,
                # système de fichiers en lecture seule, etc.
                # On affiche l'erreur et on continue avec le fichier suivant.
                print(f"Erreur lors du renommage de {file} : {e}")


# Point d'entrée du script (exécuté uniquement si lancé directement,
# pas si importé depuis un autre module Python)
if __name__ == "__main__":

    # --- Définition des arguments en ligne de commande ---
    parser = argparse.ArgumentParser(
        description=(
            "Renomme les images du dossier courant en utilisant le format "
            "'<préfixe>_<numéro>'. Exemple : monprefix_01.jpg"
        )
    )

    # Argument obligatoire : le préfixe
    parser.add_argument(
        "prefix",
        help="Préfixe pour les nouveaux noms de fichiers (ex: vacances)"
    )

    # Option facultative : mode simulation sans modification
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Affiche les renommages sans les effectuer"
    )

    args = parser.parse_args()
    renommer_images(args.prefix, dry_run=args.dry_run)
