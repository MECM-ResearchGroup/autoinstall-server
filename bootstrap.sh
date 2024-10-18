#!/bin/bash

set -e

VERSION="24.04.1"

# Create necessary directories
sudo mkdir --parents /etc/dnsmasq.d /srv/tftp/grub /var/www/html

# Download and install required software
sudo apt update
sudo apt install -y dnsmasq lighttpd wget

# Download required files and verify ISO integrity
apt download grub-common grub-efi-amd64-signed shim-signed
wget --quiet --show-progress --timestamping \
    "https://releases.ubuntu.com/${VERSION}/ubuntu-${VERSION}-live-server-amd64.iso" \
    "https://releases.ubuntu.com/${VERSION}/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS

# Copy files to the right places
sudo cp pxe.conf /etc/dnsmasq.d
sudo cp grub.cfg /srv/tftp/grub
sudo cp autoinstall.yaml "ubuntu-${VERSION}-live-server-amd64.iso" postinstall.sh /var/www/html

# Mount ISO and copy the kernel and initrd
sudo mount "ubuntu-${VERSION}-live-server-amd64.iso" /mnt
sudo cp /mnt/casper/{vmlinuz,initrd} /srv/tftp/
sudo umount -R /mnt

# Extract files needed for booting
dpkg-deb --fsys-tarfile shim-signed*deb | tar x ./usr/lib/shim/shimx64.efi.signed.latest -O | sudo tee /srv/tftp/bootx64.efi > /dev/null
dpkg-deb --fsys-tarfile grub-efi-amd64-signed*deb | tar x ./usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed -O | sudo tee /srv/tftp/grubx64.efi > /dev/null
dpkg-deb --fsys-tarfile grub-common*deb | tar x ./usr/share/grub/unicode.pf2 -O | sudo tee /srv/tftp/unicode.pf2 > /dev/null

# Start and enable services
sudo systemctl enable dnsmasq.service lighttpd.service
sudo systemctl start dnsmasq.service lighttpd.service

# Clean up
rm shim-signed*deb grub-efi-amd64-signed*deb grub-common*deb "ubuntu-${VERSION}-live-server-amd64.iso" SHA256SUMS
