#!/bin/bash

# Récupère l'utilisateur local comme valeur par défaut
default_user=$(whoami)

# Demande à l'utilisateur quel nom utiliser pour SSH
read -p "👤 Nom d'utilisateur SSH [$default_user] : " ssh_user
ssh_user=${ssh_user:-$default_user}

echo

# Liste des VMs en cours d'exécution
running_vms=$(virsh list --name | grep -v '^$')

if [ -z "$running_vms" ]; then
  echo "Aucune VM KVM en cours d'exécution."
  echo -n "👉 Pressez une touche pour continuer..."
  read -n 1 -s
  exit 1
fi

echo "📦 VMs KVM disponibles :"
echo

declare -A vm_ips
index=1
for vm in $running_vms; do
  ip=$(virsh domifaddr "$vm" | awk '/ipv4/ {print $4}' | cut -d'/' -f1)
  if [ -n "$ip" ]; then
    vm_ips[$index]="$vm:$ip"
    echo "$index) $vm → $ip"
    ((index++))
  fi
done

echo
read -p "Choisis une VM (numéro) : " choice

selected="${vm_ips[$choice]}"
if [ -z "$selected" ]; then
  echo "Choix invalide."
  exit 1
fi

vm_name=$(echo "$selected" | cut -d':' -f1)
vm_ip=$(echo "$selected" | cut -d':' -f2)

echo "🔗 Connexion à $vm_name ($vm_ip) en tant que $ssh_user..."

# Lance Kitty avec SSH
kitty @ launch --type=tab --title "SSH → $vm_name" \
  bash -c "export KITTY_SSH=1; ssh $ssh_user@$vm_ip"
