#!/bin/bash
set -e

apt update  # To get the latest package lists
apt install -y build-essential freecad gimp inkscape vim wget

#### Abaqus ####
mkdir --parents /opt/abaqus
tar --directory /opt/abaqus -xf Abq6141_extrair_na_opt.tar.gz
cp abaqus.sh /opt
cp ubuntu.recipe /opt

#### Singularity ####
export VERSION=4.0.0
wget --timestamping https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce_${VERSION}-jammy_amd64.deb
wget --timestamping https://github.com/sylabs/singularity/releases/download/v${VERSION}/sha256sums
sha256sum --check --ignore-missing sha256sums
sudo apt install -y --fix-broken ./singularity-ce_${VERSION}-jammy_amd64.deb
rm ./singularity-ce_${VERSION}-jammy_amd64.deb ./sha256sums

cd /opt
sudo singularity build --sandbox ubuntu_abq.sif ubuntu.recipe

grep -qxF "alias abaqus='sh /opt/abaqus.sh'" /etc/bash.bashrc || echo "alias abaqus='sh /opt/abaqus.sh'" >> /etc/bash.bashrc
grep -qxF "alias abacae='sh /opt/abaqus.sh cae -mesa'" /etc/bash.bashrc || echo "alias abacar='sh /opt/abaqus.sh'" >> /etc/bash.bashrc
grep -qxF "alias abaqus_server='ssh abaqus@abqserver.dema.ufscar.br -p 2419'" /etc/bash.bashrc || echo "alias abaqus_server='ssh abaqus@abqserver.dema.ufscar.br -p 2419'" >> /etc/bash.bashrc

#### Anaconda ####
export VERSION=2023.07-2
wget --timestamping https://repo.anaconda.com/archive/Anaconda3-${VERSION}-Linux-x86_64.sh
bash ./Anaconda3-${VERSION}-Linux-x86_64.sh -bp /opt/anaconda3
eval "$(/opt/anaconda3/bin/conda shell.bash hook)"
conda config --set auto_activate_base false
rm ./Anaconda3-${VERSION}-Linux-x86_64.sh
