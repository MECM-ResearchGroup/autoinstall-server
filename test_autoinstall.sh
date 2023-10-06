#!/bin/sh

set -e

# Install emulator
sudo apt update
sudo apt install qemu-system-x86

# Start web server for autoinstall file.
# Ideally we should boot from netboot.
python3 -m http.server 3003 & echo $! > ./autoinstall_server_test.pid

# Create disk image and boot vm in UEFI mode, instructing the kernel to autoinstall.
qemu-img create -f qcow2 autoinstall.img 60G
kvm -no-reboot -cpu host -m 4096 -bios OVMF.fd -drive file=autoinstall.img,if=virtio \
	-cdrom /var/www/html/ubuntu-22.04.3-live-server-amd64.iso \
	-kernel /srv/tftp/vmlinuz -initrd /srv/tftp/initrd \
	-append 'cloud-config-url=http://_gateway:3003/autoinstall.yaml autoinstall'

# Kill web server as it's not needed.
kill $(cat ./autoinstall_server_test.pid)
rm ./autoinstall_server_test.pid

# Reboot after installing.
kvm -no-reboot -cpu host -m 4096 -bios OVMF.fd \
	-drive file=autoinstall.img,if=virtio
