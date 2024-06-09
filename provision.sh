#!/bin/bash
set -exu -o pipefail

VIRSH="virsh --connect qemu:///system"

# Create pool for ISO files as necessary
if ! $VIRSH pool-info iso; then
  $VIRSH pool-define-as --name iso --type dir --target /var/lib/libvirt/iso
  $VIRSH pool-build --pool iso
  $VIRSH pool-start --pool iso
  $VIRSH pool-autostart --pool iso
fi

# Populate pool with ISO files as necessary
FEDORA_ISO="Fedora-Server-dvd-x86_64-40-1.14.iso"
if ! $VIRSH vol-info --pool iso --vol "${FEDORA_ISO}"; then
  if [ ! -f "${FEDORA_ISO}" ]; then
    wget "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Server/x86_64/iso/${FEDORA_ISO}" -O "${FEDORA_ISO}"
  fi
  size=$(stat -Lc%s "${FEDORA_ISO}")
  $VIRSH vol-create --pool iso --file /dev/stdin <<EOF
<volume>
  <name>${FEDORA_ISO}</name>
  <capacity>${size}</capacity>
  <target>
    <format type='raw'/>
    <permissions>
      <mode>0644</mode>
      <owner>0</owner>
      <group>0</group>
    </permissions>
  </target>
</volume>
EOF
  $VIRSH vol-upload --pool iso "${FEDORA_ISO}" "${FEDORA_ISO}"
fi

UBUNTU_ISO="ubuntu-24.04-desktop-amd64.iso"
if ! $VIRSH vol-info --pool iso --vol "${UBUNTU_ISO}"; then
  if [ ! -f "${UBUNTU_ISO}" ]; then
    wget "https://mirror.aarnet.edu.au/pub/ubuntu/releases/24.04/${UBUNTU_ISO}" -O "${UBUNTU_ISO}"
  fi
  size=$(stat -Lc%s "${UBUNTU_ISO}")
  $VIRSH vol-create --pool iso --file /dev/stdin <<EOF
<volume>
  <name>${UBUNTU_ISO}</name>
  <capacity>${size}</capacity>
  <target>
    <format type='raw'/>
    <permissions>
      <mode>0644</mode>
      <owner>0</owner>
      <group>0</group>
    </permissions>
  </target>
</volume>
EOF
  $VIRSH vol-upload --pool iso "${UBUNTU_ISO}" "${UBUNTU_ISO}"
fi

virt-install \
  --name=ipa.corp.lan \
  --connect qemu:///system \
  --os-variant fedora40 \
  --vcpus 4 \
  --graphics none \
  --location /var/lib/libvirt/iso/${FEDORA_ISO} \
  --memory 4096 \
  --disk size=20,bus=virtio,format=qcow2 \
  --network bridge=virbr0,model=virtio \
  --initrd-inject=ipa.ks \
  --noautoconsole \
  --wait=-1 \
  --extra-args "inst.ks=file:/ipa.ks console=ttyS0" 

