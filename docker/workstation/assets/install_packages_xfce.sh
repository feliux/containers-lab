#!/bin/bash

# Bash "strict mode", to help catch problems and bugs in the shell
# script. Every bash script you write should include this. See
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ for details
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export USER=ubuntu
export PASSWORD=ubuntu

# Update the package listing
apt update

# Install security updates
apt -y upgrade

# Install a new package without unnecessary recommended packages
apt -y install --no-install-recommends \
  xfce4 \
  xfce4-clipman-plugin \
  xfce4-cpugraph-plugin \
  xfce4-netload-plugin \
  xfce4-screenshooter \
  xfce4-taskmanager \
  xfce4-terminal \
  xfce4-xkb-plugin \
  sudo \
  xorgxrdp \
  dbus-x11 \
  xrdp \
  curl \
  git \
  wget \
  vim \
  firefox \
  default-jre \
  default-jdk \
  software-properties-common \
  apt-transport-https \
  nodejs \
  npm \
  maven \
  gpg-agent \
  krb5-user

# Create user and allow him to start xrdp
useradd -m -p $PASSWORD -s /bin/bash $USER
HASH=$(openssl passwd -1 $PASSWORD)
echo "$USER:$HASH" | /usr/sbin/chpasswd -e
echo "%$USER ALL=NOPASSWD: /usr/sbin/service xrdp start" >> /etc/sudoers.d/xrdp

# Intelli J IDEA
wget https://download.jetbrains.com/idea/ideaIC-2021.1.1.tar.gz
tar -zxvf ideaIC-2021.1.1.tar.gz
mkdir -p /opt/idea/
mv idea*/* /opt/idea
ln -s /opt/idea/bin/idea.sh /usr/local/bin/idea

# Visual Studio Code
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
apt -y install code

# Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
bash Anaconda3-2020.11-Linux-x86_64.sh -b -p /opt/conda
ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/$USER/.bashrc
echo "conda activate base" >> /home/$USER/.bashrc

# Knime https://www.knime.com/download-install/linux/6/64bit
wget https://download.knime.org/analytics-platform/linux/knime-latest-linux.gtk.x86_64.tar.gz
tar -zxvf knime-latest-linux.gtk.x86_64.tar.gz
mkdir -p /opt/knime/
mv knime*/* /opt/knime
chmod -R 0755 /opt/knime/
ln -s /opt/knime/knime /usr/local/bin/knime

# DBeaver
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
dpkg -i dbeaver-ce_latest_amd64.deb

# Postman
wget https://dl.pstmn.io/download/latest/linux64
tar -zxvf linux64
mkdir -p /opt/postman/
mv Postman*/* /opt/postman
ln -s /opt/postman/app/Postman /usr/local/bin/postman

# Protractor
npm install -g protractor

# ExpressJs
#npm install -g express

# Delete cached files we don't need anymore
apt clean
rm -rf /var/lib/apt/lists/*
