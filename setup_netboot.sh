#!/bin/bash

set -e

# create necessary directories
sudo mkdir --parents /etc/dnsmasq.d /srv/tftp/grub /var/www/html

# download and install required software
sudo apt update
sudo apt install -y dnsmasq lighttpd wget

# download required files and verify iso integrity
apt download grub-common grub-efi-amd64-signed shim-signed
wget --quiet --show-progress --timestamping https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/jammy-live-server-amd64.iso \
                                            https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/SHA256SUMS
sha256sum --check --ignore-missing SHA256SUMS

# copy files to the right places
sudo cp pxe.conf /etc/dnsmasq.d
sudo cp grub.cfg /srv/tftp/grub
sudo cp autoinstall.yaml jammy-live-server-amd64.iso /var/www/html

# mount iso and copy the kernel and initrd
sudo mount jammy-live-server-amd64.iso /mnt
sudo cp /mnt/casper/{vmlinuz,initrd} /srv/tftp/
sudo umount -R /mnt

# extract files needed for booting
dpkg-deb --fsys-tarfile shim-signed*deb | tar x ./usr/lib/shim/shimx64.efi.signed.latest -O | sudo tee /srv/tftp/bootx64.efi > /dev/null
dpkg-deb --fsys-tarfile grub-efi-amd64-signed*deb | tar x ./usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed -O | sudo tee  /srv/tftp/grubx64.efi > /dev/null
dpkg-deb --fsys-tarfile grub-common*deb | tar x ./usr/share/grub/unicode.pf2 -O | sudo tee /srv/tftp/unicode.pf2 > /dev/null

# clean up
rm shim-signed*deb grub-efi-amd64-signed*deb grub-common*deb jammy-live-server-amd64.iso SHA256SUMS
