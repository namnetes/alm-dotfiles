"""
encrypt_gpg.py
==============
Outil interactif de chiffrement et déchiffrement de fichiers via GPG.

GPG (GNU Privacy Guard) protège un fichier avec un mot de passe : seule
une personne connaissant ce mot de passe pourra l'ouvrir. Ce script
utilise le chiffrement symétrique, c'est-à-dire qu'un seul mot de passe
suffit — pas besoin de clé publique/privée.

Prérequis :
    gpg installé sur le système  →  sudo apt install gnupg
    bibliothèque python-gnupg    →  uv add python-gnupg

Utilisation :
    python encrypt_gpg.py

Le programme pose trois questions successives :
    1. Chiffrer (1) ou déchiffrer (2) ?
    2. Chemin du fichier à traiter.
    3. Mot de passe GPG (masqué à la saisie, invisible dans le terminal).

Résultat :
    Chiffrement   →  rapport.pdf      devient  rapport.pdf.gpg
    Déchiffrement →  rapport.pdf.gpg  devient  rapport.pdf
"""

import os
import getpass
from pathlib import Path

import gnupg


def _encrypt_file(
    gpg: gnupg.GPG,
    file_path: str,
    passphrase: str,
) -> None:
    """Chiffre un fichier avec GPG en mode symétrique.

    Le fichier chiffré est créé à côté du fichier original avec l'extension
    '.gpg' ajoutée. Le fichier original n'est pas supprimé.

    Exemple :
        rapport.pdf  →  rapport.pdf.gpg

    Args:
        gpg (gnupg.GPG): Instance GPG initialisée.
        file_path (str): Chemin du fichier à chiffrer.
        passphrase (str): Mot de passe pour protéger le fichier.
    """
    output_path = file_path + ".gpg"
    with open(file_path, "rb") as f:
        result = gpg.encrypt_file(
            f,
            recipients=None,    # Pas de clé publique : on utilise un mot de passe
            symmetric=True,     # Chiffrement symétrique (un seul mot de passe)
            passphrase=passphrase,
            output=output_path,
        )
    if result.ok:
        print(f"✅ Fichier chiffré créé : {output_path}")
    else:
        print(f"❌ Echec du chiffrement : {result.status}")


def _decrypt_file(
    gpg: gnupg.GPG,
    file_path: str,
    passphrase: str,
) -> None:
    """Déchiffre un fichier GPG et restaure le fichier d'origine.

    Le fichier déchiffré est créé en supprimant la dernière extension du
    nom de fichier (c'est-à-dire '.gpg'). Le fichier chiffré n'est pas
    supprimé.

    Exemple :
        rapport.pdf.gpg  →  rapport.pdf

    Args:
        gpg (gnupg.GPG): Instance GPG initialisée.
        file_path (str): Chemin du fichier .gpg à déchiffrer.
        passphrase (str): Mot de passe utilisé lors du chiffrement.
    """
    # Path.stem retire la dernière extension du nom de fichier :
    #   "rapport.pdf.gpg"  →  "rapport.pdf"
    # Path.parent donne le dossier contenant le fichier, pour reconstruire
    # le chemin complet dans le bon répertoire.
    source = Path(file_path)
    output_path = str(source.parent / source.stem)

    with open(file_path, "rb") as f:
        result = gpg.decrypt_file(
            f,
            passphrase=passphrase,
            output=output_path,
        )
    if result.ok:
        print(f"✅ Fichier déchiffré restauré : {output_path}")
    else:
        print(f"❌ Echec du déchiffrement : {result.status}")


def gpg_interact() -> None:
    """Lance le menu interactif de chiffrement / déchiffrement.

    Pose trois questions successives à l'utilisateur :
        1. L'action souhaitée (chiffrer ou déchiffrer).
        2. Le chemin du fichier à traiter.
        3. Le mot de passe GPG (masqué à la saisie).

    Délègue ensuite à _encrypt_file() ou _decrypt_file() selon le choix.
    """
    # Initialisation du moteur GPG (utilise l'installation système).
    # On l'initialise ici et non au niveau du module pour éviter un effet
    # de bord à chaque import du fichier.
    gpg = gnupg.GPG()

    print("🔐 Bienvenue dans l'outil GPG interactif")
    print("1. Chiffrer un fichier")
    print("2. Déchiffrer un fichier")
    choice = input("Que veux-tu faire ? (1/2) : ").strip()

    if choice not in ("1", "2"):
        print("❌ Choix invalide. Veuillez entrer 1 ou 2.")
        return

    file_path = input("Chemin du fichier : ").strip()
    if not os.path.isfile(file_path):
        print(f"❌ Le fichier '{file_path}' est introuvable.")
        return

    # getpass masque la saisie du mot de passe dans le terminal :
    # les caractères tapés n'apparaissent pas à l'écran.
    passphrase = getpass.getpass("Mot de passe GPG : ")

    if choice == "1":
        _encrypt_file(gpg, file_path, passphrase)
    else:
        _decrypt_file(gpg, file_path, passphrase)


if __name__ == "__main__":
    gpg_interact()
