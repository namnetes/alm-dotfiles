"""
manage_kvm.py
=============
Interface texte interactive (TUI) pour gérer les machines virtuelles KVM.

KVM (Kernel-based Virtual Machine) permet de faire tourner plusieurs
systèmes d'exploitation en parallèle sur une seule machine physique. Ce
script affiche un panneau de contrôle dans le terminal pour démarrer,
arrêter, cloner ou supprimer des VMs sans avoir à mémoriser les commandes
virsh.

Prérequis :
    libvirt-clients  →  sudo apt install libvirt-clients  (fournit virsh)
    virtinst         →  sudo apt install virtinst          (fournit virt-clone)

Utilisation :
    python manage_kvm.py

Raccourcis clavier :
    ↑ / ↓    Naviguer dans la liste des VMs
    Entrée   Démarrer ou arrêter la VM sélectionnée
    c        Cloner la VM sélectionnée
    d        Supprimer la VM sélectionnée (uniquement si arrêtée)
    r        Rafraîchir la liste
    q        Quitter
"""

import curses
import subprocess
import re
import shutil

MAX_VMS = 99


def get_vm_list() -> list[str]:
    """Récupère la liste des noms de toutes les machines virtuelles KVM.

    Utilise la commande 'virsh list --all --name' pour obtenir les noms
    des VMs, qu'elles soient en cours d'exécution ou arrêtées.

    Returns:
        list[str]: Liste des noms de VM, vide si aucune VM ou erreur.
    """
    try:
        output = subprocess.check_output(
            ['virsh', 'list', '--all', '--name'], text=True
        )
        return [line.strip() for line in output.splitlines() if line.strip()]
    except subprocess.CalledProcessError:
        return []


def get_vm_state(vm_name: str) -> str:
    """Récupère l'état actuel d'une VM (ex: 'running', 'shut off').

    Args:
        vm_name (str): Nom de la machine virtuelle.

    Returns:
        str: État de la VM, ou 'unknown' en cas d'erreur.
    """
    try:
        return subprocess.check_output(
            ['virsh', 'domstate', vm_name], text=True
        ).strip()
    except subprocess.CalledProcessError:
        return "unknown"


def get_mac_address(vm_name: str) -> str | None:
    """Récupère l'adresse MAC de l'interface réseau principale de la VM.

    Args:
        vm_name (str): Nom de la machine virtuelle.

    Returns:
        str | None: Adresse MAC, ou None si introuvable.
    """
    try:
        output = subprocess.check_output(
            ['virsh', 'domiflist', vm_name], text=True
        )
        for line in output.splitlines():
            if 'vnet' in line:
                return line.split()[4]
    except subprocess.CalledProcessError:
        pass
    return None


def get_ip_address(mac: str | None) -> str:
    """Tente de retrouver l'adresse IP associée à une adresse MAC.

    Interroge d'abord la table ARP via 'arp -an', puis via 'ip neigh'
    si la première tentative échoue. Les deux commandes lisent le cache
    réseau local de la machine hôte.

    Args:
        mac (str | None): Adresse MAC à rechercher.

    Returns:
        str: Adresse IP trouvée, 'N/A' si mac est None, 'Unknown' sinon.
    """
    if not mac:
        return "N/A"
    try:
        arp_output = subprocess.check_output(['arp', '-an'], text=True)
        # re.escape protège les caractères spéciaux de l'adresse MAC
        # (les ':' pourraient être interprétés comme quantificateurs regex).
        match = re.search(
            rf'\(([\d.]+)\).*{re.escape(mac)}', arp_output
        )
        if match:
            return match.group(1)
    except Exception:
        pass
    try:
        ip_output = subprocess.check_output(['ip', 'neigh'], text=True)
        for line in ip_output.splitlines():
            if mac in line:
                return line.split()[0]
    except Exception:
        pass
    return "Unknown"


def get_vm_info() -> list[dict[str, str | int]]:
    """Compile les informations principales de chaque VM.

    Pour chaque VM, récupère son état, son IP (si active), et détermine
    les actions disponibles selon son état actuel.

    Returns:
        list[dict[str, str | int]]: Liste de dictionnaires contenant les
            infos de chaque VM (id, name, state, ip, action, extra).
    """
    vm_data = []
    vm_list = get_vm_list()

    for idx, vm_name in enumerate(vm_list[:MAX_VMS], start=1):
        state = get_vm_state(vm_name)
        mac = get_mac_address(vm_name)

        # L'adresse IP n'est disponible que si la VM est démarrée.
        ip = get_ip_address(mac) if state == "running" else "N/A"

        # Action principale proposée selon l'état de la VM.
        if state == "running":
            action = "Arrêter"
        elif state == "shut off":
            action = "Démarrer"
        else:
            action = "N/A"

        # La suppression n'est proposée que si la VM est arrêtée,
        # pour éviter toute perte de données en cours d'exécution.
        if state == "shut off":
            extra = "Cloner / Supprimer"
        else:
            extra = "Cloner"

        vm_data.append({
            "id": idx,
            "name": vm_name,
            "state": state,
            "ip": ip,
            "action": action,
            "extra": extra,
        })
    return vm_data


def apply_action(vm_name: str, action: str) -> None:
    """Démarre ou arrête une VM selon l'action spécifiée.

    Args:
        vm_name (str): Nom de la VM.
        action (str): 'Démarrer' ou 'Arrêter'.
    """
    if action == "Démarrer":
        subprocess.run(['virsh', 'start', vm_name])
    elif action == "Arrêter":
        subprocess.run(['virsh', 'shutdown', vm_name])


def clone_vm(stdscr: curses.window, vm_name: str) -> None:
    """Clone une VM existante en demandant un nouveau nom à l'utilisateur.

    La VM source doit être arrêtée pour que le clonage fonctionne.
    Utilise 'virt-clone --auto-clone' pour copier automatiquement les
    disques virtuels de la VM.

    Args:
        stdscr (curses.window): Fenêtre curses pour l'affichage.
        vm_name (str): Nom de la VM à cloner.
    """
    curses.echo()
    stdscr.clear()
    stdscr.addstr(0, 0, "🧬 Nom de la nouvelle VM à créer : ")
    stdscr.refresh()
    new_name = stdscr.getstr(1, 0, 40).decode().strip()
    curses.noecho()

    if not new_name:
        return

    if new_name in get_vm_list():
        stdscr.addstr(3, 0, "❌ Ce nom existe déjà.")
        stdscr.getch()
        return

    if get_vm_state(vm_name) == "running":
        stdscr.addstr(3, 0, "⚠️  VM en cours. Veuillez l'arrêter d'abord.")
        stdscr.getch()
        return

    stdscr.clear()
    stdscr.addstr(0, 0, f"🔄 Clonage de '{vm_name}' vers '{new_name}'...")
    stdscr.refresh()

    result = subprocess.run(
        [
            'virt-clone', '--original', vm_name,
            '--name', new_name, '--auto-clone',
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    stdscr.clear()
    if result.returncode == 0:
        stdscr.addstr(0, 0, "✅ Clonage réussi !")
        stdscr.addstr(2, 0, f"🧬 Le clone « {new_name} » a été créé.")
    else:
        stdscr.addstr(0, 0, "❌ Échec du clonage.")
        stdscr.addstr(2, 0, result.stderr.strip())

    stdscr.addstr(4, 0, "Appuyez sur une touche pour continuer.")
    stdscr.refresh()
    stdscr.getch()


def delete_vm(stdscr: curses.window, vm_name: str) -> None:
    """Supprime une VM arrêtée ainsi que son stockage associé.

    Cette action est irréversible : le disque virtuel de la VM est
    également effacé avec l'option --remove-all-storage.

    Args:
        stdscr (curses.window): Fenêtre curses pour l'affichage.
        vm_name (str): Nom de la VM à supprimer.
    """
    stdscr.clear()
    stdscr.addstr(0, 0, f"🗑️  Suppression de la VM '{vm_name}'...")
    stdscr.refresh()

    if get_vm_state(vm_name) == "running":
        stdscr.addstr(2, 0, "⚠️  VM en cours. Veuillez l'arrêter d'abord.")
        stdscr.addstr(4, 0, "Appuyez sur une touche pour revenir.")
        stdscr.getch()
        return

    result = subprocess.run(
        ['virsh', 'undefine', vm_name, '--remove-all-storage'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    stdscr.clear()
    if result.returncode == 0:
        stdscr.addstr(0, 0, f"✅ VM '{vm_name}' supprimée.")
    else:
        stdscr.addstr(0, 0, "❌ Échec de la suppression.")
        stdscr.addstr(2, 0, result.stderr.strip())

    stdscr.addstr(4, 0, "Appuyez sur une touche pour continuer.")
    stdscr.refresh()
    stdscr.getch()


def draw_menu(
    stdscr: curses.window,
    vm_data: list[dict[str, str | int]],
    selected_idx: int,
) -> None:
    """Affiche le menu principal avec la liste des VMs.

    La VM sélectionnée est mise en surbrillance via l'attribut A_REVERSE
    (inversion des couleurs du terminal).

    Args:
        stdscr (curses.window): Fenêtre curses pour l'affichage.
        vm_data (list[dict[str, str | int]]): Liste des infos VM.
        selected_idx (int): Index (0-based) de la VM sélectionnée.
    """
    stdscr.clear()
    stdscr.addstr(
        0, 2, "🖥️  Gestion des machines virtuelles KVM", curses.A_BOLD
    )
    stdscr.addstr(1, 0, "-" * 80)
    stdscr.addstr(
        2, 0,
        f"{'ID':<3} {'Nom VM':<25} {'État':<10} {'IP':<15} {'Action':<10}"
    )
    stdscr.addstr(3, 0, "-" * 80)

    for i, vm in enumerate(vm_data):
        # curses.A_REVERSE inverse les couleurs pour simuler une sélection.
        highlight = curses.A_REVERSE if i == selected_idx else curses.A_NORMAL
        stdscr.addstr(
            4 + i, 0,
            f"{vm['id']:<3} {vm['name']:<25} {vm['state']:<10} "
            f"{vm['ip']:<15} {vm['action']:<10}",
            highlight,
        )

    stdscr.addstr(
        5 + len(vm_data), 0,
        "↑ ↓ : naviguer   Entrée : action   "
        "c : cloner   d : supprimer   r : rafraîchir   q : quitter"
    )
    stdscr.refresh()


def main(stdscr: curses.window) -> None:
    """Fonction principale exécutée dans l'interface curses.

    Initialise l'affichage, vérifie les dépendances système, puis gère
    la boucle d'événements clavier pour naviguer et agir sur les VMs.

    Args:
        stdscr (curses.window): Fenêtre curses principale, fournie
            automatiquement par curses.wrapper().
    """
    # Cache le curseur clignotant pour une interface plus propre.
    curses.curs_set(0)

    if not shutil.which("virsh"):
        stdscr.addstr(0, 0, "❌ virsh n'est pas installé.")
        stdscr.addstr(
            2, 0,
            "Installez-le avec : sudo apt install libvirt-clients"
        )
        stdscr.refresh()
        stdscr.getch()
        return

    vm_data = get_vm_info()
    if not vm_data:
        stdscr.addstr(0, 0, "⚠️  Aucune machine virtuelle détectée.")
        stdscr.addstr(
            2, 0,
            "Créez une VM avec virt-manager ou virt-install."
        )
        stdscr.refresh()
        stdscr.getch()
        return

    selected_idx = 0

    while True:
        draw_menu(stdscr, vm_data, selected_idx)
        key = stdscr.getch()

        if key == curses.KEY_UP and selected_idx > 0:
            selected_idx -= 1
        elif key == curses.KEY_DOWN and selected_idx < len(vm_data) - 1:
            selected_idx += 1
        elif key in [ord('\n'), curses.KEY_ENTER]:
            vm = vm_data[selected_idx]
            apply_action(str(vm['name']), str(vm['action']))
            vm_data = get_vm_info()
        elif key in [ord('r'), ord('R')]:
            vm_data = get_vm_info()
        elif key in [ord('c'), ord('C')]:
            vm = vm_data[selected_idx]
            clone_vm(stdscr, str(vm['name']))
            vm_data = get_vm_info()
        elif key in [ord('d'), ord('D')]:
            vm = vm_data[selected_idx]
            delete_vm(stdscr, str(vm['name']))
            vm_data = get_vm_info()
        elif key in [ord('q'), ord('Q')]:
            break


if __name__ == "__main__":
    curses.wrapper(main)
