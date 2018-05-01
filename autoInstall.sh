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


# Checking if root:
# =========================================================
echo ""
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking if root:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking if root:\e[0m" >> ${LOGFILE}
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31m  --> You need to run this program as root:\e[0m"
    echo "    sudo ./autoInstall.sh"
    echo -e "\e[31m  --> Exiting program!\e[0m"
    echo -e "\e[31m  --> You need to run this program as root:\e[0m" >> ${LOGFILE}
    echo "    sudo ./autoInstall.sh" >> ${LOGFILE}
    echo -e "\e[31m  --> Exiting program!\e[0m" >> ${LOGFILE}
    exit
fi


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


# Parsing software list:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mParsing software list:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mParsing software list:\e[0m" >> ${LOGFILE}
# Delete lines that begin with a specific character:
sed '/^#/d' config/SoftwareList.md > dummy.txt
cp dummy.txt dummy2.txt
echo > dummy.txt
sed '/^$/d' dummy2.txt > dummy.txt
rm dummy2.txt
# Generate the install list from config/SoftwareList.md:
awk '/[x]/ { print $3 }' dummy.txt > willBeInstalled.txt
# Generate uninstall list from config/SoftwareList.md:
awk '$3 == "]" { print $4 }' dummy.txt > willBeUninstalled.txt
INSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' willBeInstalled.txt)
UNINSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' willBeUninstalled.txt)
echo -e "\e[1m\e[36m  --> Will be removed:\e[0m"
echo -e "\e[1m\e[31m      ${UNINSTALL_LIST}\e[0m\n"
echo -e "\e[1m\e[36m  --> Will be installed:\e[0m"
echo -e "\e[1m\e[92m      ${INSTALL_LIST}\e[0m\n"


# Removing un-wanted softwares:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mRemoving un-wanted softwares:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mRemoving un-wanted softwares:\e[0m" >> ${LOGFILE}
sudo aptitude purge -y $UNINSTALL_LIST 2>> ${LOGFILE}


# Update and Upgrade system:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mUpdating full system:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mUpdating full system:\e[0m" >> ${LOGFILE}
aptitude update 2>> ${LOGFILE}
aptitude full-upgrade -y 2>> ${LOGFILE}
# aptitude safe-upgrade -y 2>> ${LOGFILE}  # In case of issues with full-upgrade


# Installing Softwares:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Softwares:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Softwares:\e[0m" >> ${LOGFILE}
sudo aptitude install -y $INSTALL_LIST 2>> ${LOGFILE}


# Cleaning folder:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mCleaning folder:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mCleaning folder:\e[0m" >> ${LOGFILE}
rm -f *.txt 2>>${LOGFILE}


# End of the script:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m" >> ${LOGFILE}
echo -e "  \e[4m\e[94m--> See ${LOGFILE} for more informations\e[0m\n"
