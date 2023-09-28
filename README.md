# Kubuntu autoinstall server

This shell script installs and configures tftp and http servers for netbooting an Ubuntu Server autoinstall over PXE and IPv4 on UEFI firmware.

Once the system boots, it reads the contents of `autoinstall.yaml` to install Kubuntu desktop natively on the target machine.
It uses dnsmasq and lighttpd as the tftp and http implementations respectively.

## Prerequisites
Download required files for installing abaqus from Google Drive. These are `abaqus.sh`, `ubuntu.recipe` and `Abq6141_extrair_na_opt.tar.gz`. If you do not wish to install abaqus along with the system, simply comment out the lines regarding the postinstall script on `autoinstall.yaml`.

## Installation
**Some commands require root access, so always verify the script before running it.**

Download or clone the repo and execute `./setup_netboot.sh`. Set executing permission with `chmod +x setup_netboot.sh` if needed.

Finally, move the abaqus related files to /var/www/html:

`sudo mv abaqus.sh ubuntu.recipe Abq6141_extrair_na_opt.tar.gz /var/www/html/`
