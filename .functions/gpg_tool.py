import gnupg
import os
import getpass

gpg = gnupg.GPG()

def gpg_interact():
    print("🔐 Bienvenue dans l'outil GPG interactif")
    print("1. Chiffrer un fichier")
    print("2. Déchiffrer un fichier")
    choice = input("Que veux-tu faire ? (1/2) : ").strip()

    if choice not in ['1', '2']:
        print("❌ Choix invalide.")
        return

    file_path = input("Chemin du fichier : ").strip()
    if not os.path.isfile(file_path):
        print("❌ Fichier introuvable.")
        return

    passphrase = getpass.getpass("Mot de passe GPG : ")

    if choice == '1':
        output_file = file_path + ".gpg"
        with open(file_path, 'rb') as f:
            status = gpg.encrypt_file(
                f,
                recipients=None,
                symmetric=True,
                passphrase=passphrase,
                output=output_file
            )
        if status.ok:
            print(f"✅ Fichier chiffré : {output_file}")
        else:
            print(f"❌ Erreur : {status.status}")

    elif choice == '2':
        output_file = file_path.replace(".gpg", "")
        with open(file_path, 'rb') as f:
            status = gpg.decrypt_file(
                f,
                passphrase=passphrase,
                output=output_file
            )
        if status.ok:
            print(f"✅ Fichier déchiffré : {output_file}")
        else:
            print(f"❌ Erreur : {status.status}")

if __name__ == "__main__":
    gpg_interact()
