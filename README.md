# Kubuntu autoinstall server

This shell script installs and configures tftp and http servers for netbooting an Ubuntu Server autoinstall over PXE and IPv4 on UEFI firmware.

Once the system boots, it reads the contents of `autoinstall.yaml` to install Kubuntu desktop natively on the target machine.
It uses dnsmasq and lighttpd as the tftp and http implementations respectively.

## Installation
Download the repo and execute `./setup_netboot.sh`. Change permissions with `chmod +x setup_netboot.sh` as needed.

**Some commands require root access, so always verify the script before running it.**

Finally, start and enable dnsmasq and lighthttpd with `systemctl start dnsmasq.service lighttpd.service` and `systemctl enable dnsmasq.service lighttpd.service`.
