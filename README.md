# Linux Lab

Linux scripts and snippets.

## Work in progress

Things to do

- Make Ansible playbook for post-install tasks.

### ipa.corp.lan

- Automate IPA server install

```bash
dnf install -y freeipa-server freeipa-server-dns freeipa-client
echo '192.168.123.2 ipa.corp.lan' >> /etc/hosts
ipa-server-install --realm=CORP.LAN --unattended --setup-dns --ds-password='t3mpp@ssw0rd!' --admin-password='t3mpp@ssw0rd!' --forwarder=192.168.123.1
```

- Automate firewall setup

```
firewall-cmd --zone=FedoraServer --add-service http --permanent
firewall-cmd --zone=FedoraServer --add-service https --permanent
firewall-cmd --zone=FedoraServer --add-service ldap --permanent
firewall-cmd --zone=FedoraServer --add-service ldaps --permanent
firewall-cmd --zone=FedoraServer --add-service kerberos --permanent
firewall-cmd --zone=FedoraServer --add-service dns --permanent
firewall-cmd --zone=FedoraServer --add-service ntp --permanent
firewall-cmd --reload
```

### desktop.corp.lan

- Use `autoinstall.yml` or equivalent to provision VM via `virt-install`.
- Provision Chrome & provision a policy to make kerberos work

```bash
sudo mkdir -p /etc/opt/chrome/policies/managed
sudo tee  /etc/opt/chrome/policies/managed/kerberos.json << EOF
{
  "AuthServerAllowlist": "*.corp.lan",
  "AuthNegotiateDelegateAllowlist": "*.corp.lan"
}
EOF
/bin/sudo /bin/chmod 0644 /etc/opt/chrome/policies/managed/kerberos.json
```

## Future ideas

Identity

- IPA server, likely needs something RHEL-based
- IPA client, installable on wider range of platforms
- Possible alternative: kanidm could run on debian https://github.com/kanidm/kanidm
- Possible extension: Samba DC for Windows clients (can they log in to Linux accounts though?)

Config management

- Ansible & AWX

VDI

- GNOME remote desktop
- Guacamole?

VPN
- OpenVPN due to good authentication options.

Virtualization
- KVM
- Virt-install
- Proxmox

Applications
- A wordpress or similar
- Gitea
- A container host of some sort
- Backups

Provisioning

- Debian pre-seed
- cloud-init
