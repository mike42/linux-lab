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
ISO_NAME="Fedora-Server-dvd-x86_64-40-1.14"
if ! $VIRSH vol-info --pool iso --vol "${ISO_NAME}.iso"; then
  if [ ! -f "${ISO_NAME}.iso" ]; then
    wget "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Server/x86_64/iso/${ISO_NAME}.iso" -O "${ISO_NAME}.iso"
  fi
  size=$(stat -Lc%s "${ISO_NAME}.iso")
  $VIRSH vol-create --pool iso --file /dev/stdin <<EOF
<volume>
  <name>${ISO_NAME}.iso</name>
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
  $VIRSH vol-upload --pool iso "${ISO_NAME}.iso" "${ISO_NAME}.iso"
fi

virt-install \
  --name=fedora-test \
  --connect qemu:///system \
  --os-variant fedora40 \
  --vcpus 4 \
  --graphics none \
  --location /var/lib/libvirt/iso/${ISO_NAME}.iso \
  --memory 4096 \
  --disk size=20,bus=virtio,format=qcow2 \
  --network bridge=virbr0,model=virtio \
  --initrd-inject=fedora.ks \
  --noautoconsole \
  --wait=-1 \
  --extra-args "inst.ks=file:/fedora.ks console=ttyS0" 

