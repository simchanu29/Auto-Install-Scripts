#! /bin/bash


#               Auto Install Scripts
# =========================================================
# This script performs a full upgrade of the system, then
# install a pre-defined list of softwares!
#
# =========================================================


# Generating error logfile:
# =========================================================
LOGFILE="Install_"$(date '+%Y-%m-%d-%H-%M-%S')".log"
touch ${LOGFILE}


# Checking the internet connection:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking if the computer is connected to the internet:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking if the computer is connected to the internet:\e[0m" >> ${LOGFILE}

CONNECTION=$(ping -q -c 2 www.ubuntu.com > /dev/null && echo 0 || echo 1)
if [ ${CONNECTION} -eq 0 ]; then
    echo -e "\e[1m\e[36m  --> Connected to the internet!\e[0m\n"
    echo -e "\e[1m\e[36m  --> Connected to the internet!\e[0m\n" >> ${LOGFILE}
else
    echo -e "\e[1m\e[31m  --> Not connected to the internet!\e[0m"
    echo -e "\e[1m\e[31m  --> Exiting program!\e[0m"
    echo -e "\e[1m\e[31m  --> Not connected to the internet!\e[0m" >> ${LOGFILE}
    echo -e "\e[1m\e[31m  --> Exiting program!\e[0m" >> ${LOGFILE}
    exit 0
fi

 
# Adding Canonical's partner repository:
# =========================================================
echo -e "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository:\e[0m" >> ${LOGFILE}
sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list 2>> ${LOGFILE}


# Checking if aptitude is already present in the system:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking Aptitude:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking Aptitude:\e[0m" >> ${LOGFILE}
if hash aptitude 2>/dev/null; then
    echo -e "\e[1m\e[36m  --> aptitude is already installed!\e[0m\n"
    echo -e "\e[1m\e[36m  --> aptitude is already installed!\e[0m\n" >> ${LOGFILE}
else
    # Install aptitude for futures installations:
    echo -e "\e[1m\e[31m  --> aptitude is not installed!\e[0m\n"
    echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude:\e[0m"
    echo -e "\e[1m\e[31m  --> aptitude is not installed!\e[0m\n" >> ${LOGFILE}
    echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude:\e[0m" >> ${LOGFILE}
    apt update 2>> ${LOGFILE}
    apt install -y aptitude 2>> ${LOGFILE}
fi


# Update and Upgrade system:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mUpdating full system:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mUpdating full system:\e[0m" >> ${LOGFILE}
aptitude update 2>> ${LOGFILE}
aptitude full-upgrade -y 2>> ${LOGFILE}
# aptitude safe-upgrade -y 2>> ${LOGFILE}  # In case of issues with full-upgrade

echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m\n"
echo -e "\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m\n" >> ${LOGFILE}
