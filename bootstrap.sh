#!/bin/bash

set -e

VERSION="24.04.1"

# Create necessary directories
sudo mkdir --parents /etc/dnsmasq.d /srv/tftp/grub /var/www/html

# Download and install required software
sudo apt update
sudo apt install -y dnsmasq lighttpd wget

# Download required files and verify ISO integrity
wget --quiet --show-progress --timestamping \
    "https://releases.ubuntu.com/${VERSION}/ubuntu-${VERSION}-netboot-amd64.tar.gz" \
    "https://releases.ubuntu.com/${VERSION}/ubuntu-${VERSION}-live-server-amd64.iso" \
    "https://releases.ubuntu.com/${VERSION}/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS

tar -xf "ubuntu-${VERSION}-netboot-amd64.tar.gz"

# Copy files to the right places
sudo cp -r amd64/* /srv/tftp
sudo cp pxe.conf /etc/dnsmasq.d
sudo cp grub.cfg /srv/tftp/grub
sudo cp autoinstall.yaml "ubuntu-${VERSION}-live-server-amd64.iso" postinstall.sh /var/www/html

# Start and enable services
sudo systemctl enable dnsmasq.service lighttpd.service
sudo systemctl start dnsmasq.service lighttpd.service

# Clean up
rm -r amd64/ ubuntu* SHA256SUMS
