"""
check_csv.py
============
Script de vérification de fichiers CSV.

Vérifie que toutes les lignes d'un fichier CSV ont le même nombre de
colonnes, ce qui garantit un fichier bien formé avant de l'importer
dans un tableur ou un programme.

Fonctionnalités :
    - Séparateur configurable : virgule, point-virgule, tabulation, etc.
    - Mode strict  : s'arrête et affiche la première erreur détectée.
    - Mode complet : collecte toutes les erreurs et les affiche à la fin.
    - Mode silencieux (-q) : aucune sortie, uniquement le code de retour.

Exemples d'utilisation :
    python check_csv.py -f fichier.csv -d ','
    python check_csv.py -f fichier.tsv -d '\\t' --strict
    python check_csv.py -f donnees.csv -q

Codes de retour shell :
    0  →  fichier valide
    1  →  fichier invalide, introuvable ou vide
"""

import csv
import sys
import os
import argparse


def check_csv_columns(
    file_path: str,
    delimiter: str,
    verbose: bool = True,
    strict: bool = False,
) -> bool:
    """Vérifie que chaque ligne d'un fichier CSV a le même nombre de colonnes.

    La première ligne sert de référence : son nombre de colonnes est comparé
    à toutes les lignes suivantes. En mode strict, le premier écart arrête
    immédiatement le traitement. En mode normal, toutes les erreurs sont
    collectées puis affichées ensemble à la fin.

    Args:
        file_path (str): Chemin du fichier CSV à analyser.
        delimiter (str): Caractère séparateur utilisé dans le fichier.
        verbose (bool): Si True, affiche les messages (défaut : True).
        strict (bool): Si True, s'arrête à la première erreur (défaut : False).

    Returns:
        bool: True si toutes les lignes ont le même nombre de colonnes.
    """
    try:
        with open(file_path, mode="r", newline="", encoding="utf-8") as f:
            reader = csv.reader(f, delimiter=delimiter)

            # Lecture de la première ligne : elle fixe le nombre de colonnes
            # attendu pour tout le reste du fichier.
            try:
                first_row = next(reader)
            except StopIteration:
                # next() lève StopIteration si le fichier est vide.
                if verbose:
                    print(f"Erreur : le fichier '{file_path}' est vide.")
                return False

            num_columns = len(first_row)

            # Liste des erreurs collectées : chaque entrée = (numéro de ligne,
            # nombre de colonnes trouvées sur cette ligne).
            errors: list[tuple[int, int]] = []

            for line_number, row in enumerate(reader, start=2):
                if len(row) != num_columns:
                    if strict:
                        # Mode strict : on s'arrête immédiatement.
                        if verbose:
                            print(
                                f"Le fichier '{file_path}' comporte "
                                f"{num_columns} colonnes."
                            )
                            print(
                                f"Erreur à la ligne {line_number}: "
                                f"{len(row)} colonnes trouvées."
                            )
                        return False
                    errors.append((line_number, len(row)))

        # Affichage groupé de toutes les erreurs collectées (mode non-strict).
        if errors:
            if verbose:
                print(
                    f"Le fichier '{file_path}' comporte "
                    f"{num_columns} colonnes."
                )
                print("Des erreurs ont été détectées :")
                # rjust aligne les numéros de ligne sur la même largeur
                # pour que les messages soient lisibles en colonne.
                max_line = max(line for line, _ in errors)
                width = len(str(max_line))
                for line, found in errors:
                    print(
                        f"  Ligne {str(line).rjust(width)}: "
                        f"{found} colonnes trouvées "
                        f"(attendu : {num_columns})."
                    )
            return False

        if verbose:
            print(
                f"OK : '{file_path}' est valide "
                f"({num_columns} colonnes, aucune erreur détectée)."
            )
        return True

    except FileNotFoundError:
        if verbose:
            print(f"Erreur : le fichier '{file_path}' est introuvable.")
        return False
    except Exception as e:
        if verbose:
            print(f"Erreur inattendue : {e}")
        return False


def main() -> None:
    """Point d'entrée principal. Gère les arguments et lance la vérification."""
    parser = argparse.ArgumentParser(
        description=(
            "Vérifie que toutes les lignes d'un CSV "
            "ont le même nombre de colonnes."
        )
    )
    parser.add_argument(
        "-f", "--infile", required=True,
        help="Chemin du fichier CSV à traiter."
    )
    parser.add_argument(
        "-d", "--delimiter", default=";",
        help="Délimiteur du CSV (ex: ',', ';', '|', '\\t'). Défaut : ';'."
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true",
        help="Mode silencieux (aucune sortie sur la console)."
    )
    parser.add_argument(
        "--strict", action="store_true",
        help="Mode strict : s'arrête à la première erreur détectée."
    )

    args = parser.parse_args()

    # La tabulation est passée en ligne de commande comme la chaîne '\\t'.
    # On la convertit en vrai caractère tabulation pour que le module csv
    # puisse l'utiliser comme séparateur.
    if args.delimiter == r"\t":
        args.delimiter = "\t"

    if not os.path.isfile(args.infile):
        if not args.quiet:
            print(f"Erreur : le fichier '{args.infile}' n'existe pas.")
        sys.exit(1)

    result = check_csv_columns(
        args.infile,
        args.delimiter,
        verbose=not args.quiet,
        strict=args.strict,
    )
    sys.exit(0 if result else 1)


if __name__ == "__main__":
    main()
