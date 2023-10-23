#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
LIGHTGREY='\033[0;37m'
POSTINSTALL_DIR='/postinstall'

echo -e "\n${RED}This script will install software used by the MECM project. It will need SUPERUSER access to execute some commands. Always review the script before executing since it can cause nasty damage otherwise.${LIGHTGREY}\n"

# Reset network interface to get dns.
ip link set `ip --brief link | awk '$1 !~ "lo|vir|wl" { print $1}'` down
sleep 10
ip link set `ip --brief link | awk '$1 !~ "lo|vir|wl" { print $1}'` up
sleep 10
apt update  # To get the latest package lists
apt upgrade -y
apt install -y build-essential freecad gimp inkscape # commonly used packages
snap refresh
snap install firefox

# Set custom locale definitions
localectl set-locale LC_NUMERIC=pt_BR.UTF-8 \
      LC_TIME=pt_BR.UTF-8 LC_MONETARY=pt_BR.UTF-8 LC_PAPER=pt_BR.UTF-8 \
      LC_NAME=pt_BR.UTF-8 LC_ADDRESS=pt_BR.UTF-8 LC_TELEPHONE=pt_BR.UTF-8 \
      LC_MEASUREMENT=pt_BR.UTF-8 LC_IDENTIFICATION=pt_BR.UTF-8

#### Abaqus ####
echo -e "\n${BLUE}Installing Abaqus${LIGHTGREY}"
mkdir --parents /opt/abaqus
tar --checkpoint=10000 --checkpoint-action=. --directory /opt/abaqus -xf ${POSTINSTALL_DIR}/Abq6141_extrair_na_opt.tar.gz
chmod +x ${POSTINSTALL_DIR}/abaqus.sh
mv ${POSTINSTALL_DIR}/abaqus.sh /opt
mv ${POSTINSTALL_DIR}/ubuntu.recipe /opt
echo -e "\n${GREEN}Abaqus installed successfully!${LIGHTGREY}\n"
rm ${POSTINSTALL_DIR}/Abq6141_extrair_na_opt.tar.gz

#### Singularity ####
export VERSION=4.0.0
wget --timestamping https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce_${VERSION}-jammy_amd64.deb
wget --timestamping https://github.com/sylabs/singularity/releases/download/v${VERSION}/sha256sums
sha256sum --check --ignore-missing sha256sums
sudo apt install -y --fix-broken ./singularity-ce_${VERSION}-jammy_amd64.deb
rm ./singularity-ce_${VERSION}-jammy_amd64.deb ./sha256sums

echo -e "\n${BLUE}Building Abaqus container${LIGHTGREY}\n"
singularity build --sandbox /opt/ubuntu_abq.sif /opt/ubuntu.recipe
echo -e "\n${GREEN}Abaqus container built successfully${LIGHTGREY}\n"

echo -e "\n${BLUE}Setting bash aliases for Abaqus${LIGHTGREY}\n"
echo "alias abaqus='sh /opt/abaqus.sh'" >> /etc/bash.bashrc
echo "alias abacae='sh /opt/abaqus.sh cae -mesa'" >> /etc/bash.bashrc
echo "alias abaqus_server='ssh abaqus@abqserver.dema.ufscar.br -p 24199'" >> /etc/bash.bashrc

#### Anaconda ####
export VERSION=2023.09-0
echo -e "\n${BLUE}Downloading Anaconda ${VERSION}${LIGHTGREY}\n"
wget --quiet --show-progress --timestamping https://repo.anaconda.com/archive/Anaconda3-${VERSION}-Linux-x86_64.sh
echo -e "\n${BLUE}Installing Anaconda${LIGHTGREY}\n"
bash ./Anaconda3-${VERSION}-Linux-x86_64.sh -bp /opt/anaconda3
eval "$(/opt/anaconda3/bin/conda shell.bash hook)"
conda config --set auto_activate_base false
echo -e "\n${GREEN}Anaconda installed successfully!${LIGHTGREY}\n"
rm ./Anaconda3-${VERSION}-Linux-x86_64.sh

#### MATLAB ####
echo -e "\n${BLUE}Installing MATLAB${LIGHTGREY}\n"
unzip -d ${POSTINSTALL_DIR}/MATLAB ${POSTINSTALL_DIR}/MATLAB_R2019a_Linux_UFSCar.zip
rm ${POSTINSTALL_DIR}/MATLAB_R2019a_Linux_UFSCar.zip
chmod -R u+x ${POSTINSTALL_DIR}/MATLAB
${POSTINSTALL_DIR}/MATLAB/install -inputFile ${POSTINSTALL_DIR}/installer_input.txt
echo "alias matlab='/opt/MATLAB/R2019a/bin/matlab'" >> /etc/bash.bashrc
echo -e "\n${GREEN}MATLAB installed successfully!${LIGHTGREY}\n"
rm -r ${POSTINSTALL_DIR}/{MATLAB,installer_input.txt,network.lic}

#### Setup AD and nfs ####
echo -e "\n${BLUE}Now setting up Active Directory and NFS${LIGHTGREY}\n"
apt install -y realmd adcli samba-common-bin libnss-sss libpam-sss sssd sssd-tools oddjob oddjob-mkhomedir packagekit nis nfs-common
realm discover lsc.dema.ufscar.br
realm join lsc.dema.ufscar.br
echo "crio:/home	/home	nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
echo "domain lsc.dema.ufscar.br server crio.lsc.dema.ufscar.br" >> /etc/yp.conf
echo "lsc.dema.ufscar.br" > /etc/defaultdomain
echo "session optional        pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session
sed -i 's/# passwd:         files systemd/passwd:         files systemd nis sss/' /etc/nsswitch.conf
sed -i 's/# group:          files systemd/group:          files systemd nis sss/' /etc/nsswitch.conf
sed -i 's/# shadow:         files systemd/shadow:         files nis sss/' /etc/nsswitch.conf
sed -i 's/# hosts:          files dns/hosts:          files dns nis/' /etc/nsswitch.conf
systemctl restart rpcbind nscd ypbind
systemctl enable rpcbind nscd ypbind ypserv.service yppasswdd.service ypxfrd.service
echo -e "\n${GREEN}AD and NFS set up successfully!${LIGHTGREY}\n"

echo -e "\n${GREEN}The script finished executing with no errors. Reboot to apply some remaining configurations.${LIGHTGREY}\n"
rm -r ${POSTINSTALL_DIR}
