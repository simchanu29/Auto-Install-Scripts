#! /bin/bash

# Generating error logfile:
LOGFILE="log_"$(date '+%Y-%m-%d-%H-%M-%S')".log"
touch ${LOGFILE}

# Adding Canonical's partner repository:
echo -e "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository\e[0m" >> ${LOGFILE}
sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list 2>> ${LOGFILE}

# Checking if aptitude is already present in the system:
if hash aptitude 2>/dev/null; then
    echo -e "\n\e[1m\e[36m  --> aptitude is already installed\e[0m"
    echo -e "\n\e[1m\e[36m  --> aptitude is already installed\e[0m" >> ${LOGFILE}
else
    # Install aptitude for futures installations:
    echo -e "\n\e[1m\e[31m  --> aptitude is not installed!\e[0m"
    echo -e "\n\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude\e[0m"
    echo -e "\n\e[1m\e[31m  --> aptitude is not installed!\e[0m" >> ${LOGFILE}
    echo -e "\n\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude\e[0m" >> ${LOGFILE}
    apt update 2>> ${LOGFILE}
    apt install -y aptitude 2>> ${LOGFILE}
fi

# Update and Upgrade system:
echo -e "\n\e[1m\e[32m==> \e[1m\e[37mUpdating full system\e[0m"
echo -e "\n\e[1m\e[32m==> \e[1m\e[37mUpdating full system\e[0m" >> ${LOGFILE}
aptitude update 2>> ${LOGFILE}
aptitude dist-upgrade -y 2>> ${LOGFILE}

echo -e "\n\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m\n"
echo -e "\n\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m\n" >> ${LOGFILE}
