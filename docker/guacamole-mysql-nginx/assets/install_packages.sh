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
  lubuntu-desktop \
  sudo \
  xorgxrdp \
  dbus-x11 \
  xrdp \
  wget \
  gpg-agent

# Create user and allow him to start xrdp
useradd -m -p $PASSWORD -s /bin/bash $USER
HASH=$(openssl passwd -1 $PASSWORD)
echo "$USER:$HASH" | /usr/sbin/chpasswd -e
echo "%$USER ALL=NOPASSWD: /usr/sbin/service xrdp start" >> /etc/sudoers.d/xrdp

# Delete cached files we don't need anymore
apt clean
rm -rf /var/lib/apt/lists/*