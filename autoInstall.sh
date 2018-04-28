#! /bin/bash

# Adding Canonical's partner repository:
sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list

# Checking if aptitude is already present in the system:
if hash aptitude 2>/dev/null; then
    echo "aptitude is already installed"
else
    # Install aptitude for futures installations:
    echo "aptitude is not installed!"
    echo "=> Installing Aptitude"
    apt update
    apt install -y aptitude
fi

# Update and Upgrade system:
echo "Updating full system"
aptitude update
# Upgrading packages:
#aptitude safe-upgrade -y
# Upgrading packages and distrib:
#aptitude dist-upgrade -y
aptitude upgrade -y

echo "Completed !"
