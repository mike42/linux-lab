#!/bin/bash
set -exu -o pipefail

ISO_NAME="Fedora-Server-dvd-x86_64-40-1.14"
if [ ! -f /tmp/iso/${ISO_NAME}.iso ]; then
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/40/Server/x86_64/iso/${ISO_NAME}.iso -O /tmp/iso/${ISO_NAME}.iso
fi

virt-install \
  --name=fedora-test \
  --connect qemu:///system \
  --os-variant fedora40 \
  --vcpus 4 \
  --graphics none \
  --location /tmp/iso/${ISO_NAME}.iso \
  --memory 4096 \
  --disk size=20,bus=virtio,format=qcow2 \
  --network bridge=virbr0,model=virtio \
  --initrd-inject=fedora.ks \
  --noautoconsole \
  --wait=-1 \
  --extra-args "inst.ks=file:/fedora.ks console=ttyS0" 

