#!/bin/bash

# Bash "strict mode", to help catch problems and bugs in the shell
# script. Every bash script you write should include this. See
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ for details
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export USER=guacamole
export PASSWORD=changeme

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
  xorgxrdp \
  dbus-x11 \
  xrdp \
  git \
  curl \
  krb5-user

adduser $USER --home /home/$USER
passwd $USER $PASSWORD

# Delete cached files we don't need anymore
apt clean
rm -rf /var/lib/apt/lists/*