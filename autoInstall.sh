#! /bin/bash

# Adding Canonical's partner repository:
echo -e "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository\e[0m"
sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list

# Checking if aptitude is already present in the system:
if hash aptitude 2>/dev/null; then
    echo -e "\n\e[1m\e[36m  --> aptitude is already installed\e[0m"
else
    # Install aptitude for futures installations:
    echo -e "\n\e[1m\e[31m  --> aptitude is not installed!\e[0m"
    echo -e "\n\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude\e[0m"
    apt update
    apt install -y aptitude
fi

# Update and Upgrade system:
echo -e "\n\e[1m\e[32m==> \e[1m\e[37mUpdating full system\e[0m"
aptitude update
aptitude dist-upgrade -y

echo -e "\n\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m\n"
