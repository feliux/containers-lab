#!/bin/bash

# Bash "strict mode", to help catch problems and bugs in the shell
# script. Every bash script you write should include this. See
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ for details
set -euo pipefail

# Install required packages
yum -y install wget unzip dos2unix

# Install Tibco Spotfire
rpm -ivh tss-$VERSION.x86_64.rpm

# Configure Spotfire
/opt/tibco/tss/$VERSION/configure -d -s 80 -r 9080 -b 9443

dos2unix fixservername.sh
chmod 755 fixservername.sh

# Move psql driver to Spotfire classpath
mv postgresql-42.2.19.jar /opt/tibco/tss/$VERSION/tomcat/spotfire-boot-lib/

# Remove unnecessary files
rm -f tss-$VERSION.x86_64.rpm
