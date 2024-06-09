# Keyboard layouts
keyboard --xlayouts='au'
# System language
lang en_AU.UTF-8

%packages
@^server-product-environment

%end

# Run the Setup Agent on first boot
firstboot --enable

network --device=enp1s0 --onboot=on --activate
network --bootproto=static --ip=192.168.123.2 --netmask=255.255.255.0 --gateway=192.168.123.1 --nameserver=192.168.123.1
network --hostname=fedora-test.lan

# Generated using Blivet version 3.9.1
ignoredisk --only-use=vda
# System bootloader configuration
bootloader --location=mbr --boot-drive=vda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part biosboot --fstype="biosboot" --ondisk=vda --size=1
part /boot --fstype="xfs" --ondisk=vda --size=1024
part pv.48 --fstype="lvmpv" --ondisk=vda --size=19453
volgroup fedora --pesize=4096 pv.48
logvol / --fstype="xfs" --grow --maxsize=15360 --size=2048 --name=root --vgname=fedora

# System timezone
timezone Australia/Melbourne --utc

# Root password
rootpw --lock
# Note user password is 't3mpp@ssw0rd!'
user --groups=wheel --name=tempadmin --password=$y$j9T$L.UFhUGuM3u1Wv9wu5cF0MYI$AzupObmSVrnOnHtCLF4LkJm.F6nvE7e6gQ67O4gYW06 --iscrypted --gecos="tempadmin"

poweroff

