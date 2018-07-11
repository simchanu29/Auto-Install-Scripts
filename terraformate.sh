#! /bin/bash


#   ___ ____ ____ ____ ____ ____ ____ ____ _  _ ____ ___ ____ 
#    |  |___ |__/ |__/ |__| |___ |  | |__/ |\/| |__|  |  |___ 
#    |  |___ |  \ |  \ |  | |    |__| |  \ |  | |  |  |  |___                                                         
# =============================================================
# This script performs a full upgrade of the system, then
# install a pre-defined list of softwares!
# =============================================================


echo -e "###################################################################"
echo -e "##   ___ ____ ____ ____ ____ ____ ____ ____ _  _ ____ ___ ____   ##"
echo -e "##    |  |___ |__/ |__/ |__| |___ |  | |__/ |\/| |__|  |  |___   ##"
echo -e "##    |  |___ |  \ |  \ |  | |    |__| |  \ |  | |  |  |  |___   ##"
echo -e "##   __________________________________________________________  ##"
echo -e "###################################################################"
echo -e "\t\t Version 0.4.0"


# Generating logfile:
# =========================================================
if [ ! -d logs ]; then
    mkdir logs
fi
LOGFILE="logs/Install_"$(date '+%Y-%m-%d-%H-%M-%S')".log"
touch ${LOGFILE}

# loginfo function
function loginfo () {
    STRING=$1
    echo -e $STRING
    echo -e $STRING >> ${LOGFILE}
}

# Generating temp folder:
# =========================================================
mkdir temp
touch temp/temp.txt
TEMPFILE1=temp/temp.txt
touch temp/temp2.txt
TEMPFILE2=temp/temp2.txt

function main () {

# Checking if root:
# =========================================================
echo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mChecking if root:\e[0m"
if [ "$EUID" -ne 0 ]; then
    loginfo "\e[31m  --> You need to run this program as root:\e[0m"
    loginfo "    sudo ./autoInstall.sh"
    loginfo "\e[31m  --> Exiting program!\e[0m"
    exit
else
    loginfo "\e[1m\e[92m  --> Done!\e[0m"



# Checking the internet connection:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
loginfo "\e[1m\e[32m==> \e[1m\e[37mChecking if the computer is connected to the internet:\e[0m"

CONNECTION=$(ping -q -c 2 www.ubuntu.com > /dev/null && echo 0 || echo 1)
if [ ${CONNECTION} -eq 0 ]; then
    loginfo "\e[1m\e[92m  --> Connected to the internet!\e[0m"
else
    loginfo "\e[1m\e[31m  --> Not connected to the internet!\e[0m"
    loginfo "\e[1m\e[31m  --> Exiting program!\e[0m"
    exit 0
fi



# Adding Canonical's partner repository:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository:\e[0m"
sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list 2>> ${LOGFILE}
if [ $? == 0 ]; then
    loginfo "\e[1m\e[92m  --> Done!\e[0m"
else
    loginfo "\e[1m\e[31m  --> Error!\e[0m"
fi



# Checking if aptitude is already present in the system:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mChecking Aptitude:\e[0m"
if hash aptitude 2>/dev/null; then
    loginfo "\e[1m\e[92m  --> aptitude is already installed!\e[0m"
else
    # Install aptitude for futures installations:
    loginfo "\e[1m\e[31m  --> aptitude is not installed!\e[0m"
    loginfo ""
    loginfo "\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude:\e[0m"
    apt update 2>> ${LOGFILE}
    apt install -y aptitude 2>> ${LOGFILE}
    if [ $? == 0 ]; then
        loginfo "\e[1m\e[92m  --> Aptitude installed!\e[0m"
    else
        loginfo "\e[1m\e[31m  --> Error! Exiting!\e[0m"
        exit
    fi
fi

echo ""
echo ""
echo -e "\t\e[94m##################################################"
echo -e "\t##                                              ##"
echo -e "\t##     The following steps could be long\e[5m...\e[0m\e[94m     ##"
echo -e "\t##     --> It is time to take a break/\e[5m\e[93mcoffee\e[0m\e[94m    ##"
echo -e "\t##                                              ##"
echo -e "\t##################################################\e[0m"
echo ""


# Parsing software list:
# =========================================================
echo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mParsing software list:\e[0m"
# Delete lines that begin with a specific character:
sed '/^#/d' config/SoftwareList.md > ${TEMPFILE1}
cp ${TEMPFILE1} ${TEMPFILE2}
sed '/^$/d' ${TEMPFILE2} > ${TEMPFILE1}
# Generate the install list from config/SoftwareList.md:
awk '/[x]/ { print $3 }' ${TEMPFILE1} > temp/willBeInstalled.txt
# Generate uninstall list from config/SoftwareList.md:
awk '$3 == "]" { print $4 }' ${TEMPFILE1} > temp/willBeUninstalled.txt
INSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' temp/willBeInstalled.txt)
# UNINSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' willBeUninstalled.txt)
# loginfo "\e[1m\e[36m  --> Will be removed:\e[0m"
# loginfo "\e[1m\e[31m      ${UNINSTALL_LIST}\e[0m\n"
# loginfo "\e[1m\e[36m  --> Will be installed:\e[0m"
# loginfo "\e[1m\e[92m      ${INSTALL_LIST}\e[0m"
if [ $? == 0 ]; then
        loginfo "\e[1m\e[92m  --> Done!\e[0m"
    else
        loginfo "\e[1m\e[31m  --> Error!\e[0m"
        exit
    fi



# Removing un-wanted softwares:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mRemoving un-wanted softwares:\e[0m"

# Emptying "temp.txt":
echo -n > ${TEMPFILE1}

# Checking if the softwares that are planned to be uninstalled are already present on the system:
loginfo "\e[1m\e[36m  --> Checking the system!\e[0m"
loginfo "\e[1m\e[36m  --> Checking the system!\e[0m" >> ${LOGFILE}
N_LINES=$(wc -l < temp/willBeUninstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeUninstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        echo ${SOFT} >> ${TEMPFILE1}
        loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mInstalled\e[0m]"
    # else
        # loginfo "\e[1m\e[92m  --> ${SOFT} is not installed!\e[0m"
    fi
done
UNINSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' ${TEMPFILE1})
if [ -s ${TEMPFILE1} ]
then 
    loginfo "\e[1m\e[36m  --> Will be removed:\e[0m"
    loginfo "\e[1m\e[31m      ${UNINSTALL_LIST}\e[0m"
    sudo aptitude purge -y $UNINSTALL_LIST 2>> ${LOGFILE}
else
    loginfo "\e[1m\e[92m  --> Nothing will be removed!\e[0m"
fi



# Update and Upgrade system:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mUpdating full system:\e[0m"
aptitude update 2>> ${LOGFILE}
if [ $? == 0 ]; then
    loginfo "\e[1m\e[92m  --> Update Done!\e[0m"
else
    loginfo "\e[1m\e[31m  --> Update Error!\e[0m"
fi

aptitude full-upgrade -y 2>> ${LOGFILE}
# aptitude safe-upgrade -y 2>> ${LOGFILE}  # In case of issues with full-upgrade
if [ $? == 0 ]; then
    loginfo "\e[1m\e[92m  --> Upgrade Done!\e[0m"
else
    loginfo "\e[1m\e[31m  --> Update Error!\e[0m"
fi



# Installing Softwares:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mInstalling Softwares:\e[0m"

# Emptying "temp.txt":
echo -n > ${TEMPFILE1}

# Checking if the softwares that are planned to be installed are already present on the system:
loginfo "\e[1m\e[36m  --> Checking the system!\e[0m"
N_LINES=$(wc -l < temp/willBeInstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeInstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
    else
        # Metapackages don't validate the previous test
        dpkg-query -s ${SOFT} > /dev/null 2> /dev/null
        if [ $? == 0 ]; then
            loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
        else
            # Definitively not installed!
            echo ${SOFT} >> ${TEMPFILE1}
            loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mMissing\e[0m]"
        fi
    fi
done

INSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' ${TEMPFILE1})
if [ -s ${TEMPFILE1} ]
then 
    loginfo "\e[1m\e[36m  --> Will be installed:\e[0m"
    loginfo "\e[1m\e[92m      ${INSTALL_LIST}\e[0m"
    sudo aptitude install -y $INSTALL_LIST 2>> ${LOGFILE}
else
    loginfo "\e[1m\e[92m  --> Nothing will be installed!\e[0m"
fi



# Removing old dependencies which could have been forgotten:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mRemoving old dependencies which could have been forgotten:\e[0m"
apt autoremove 2>> ${LOGFILE}
if [ $? == 0 ]; then
    loginfo "\e[1m\e[92m  --> Done!\e[0m"
else
    loginfo "\e[1m\e[31m  --> Error!\e[0m"
fi



# Summary:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mSummary:\e[0m"

# Checking if the softwares which were planned to be uninstalled are still present on the system:
loginfo "\e[1m\e[36m  --> Checking uninstall list!\e[0m"
N_LINES=$(wc -l < temp/willBeUninstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeUninstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mPresent\e[0m]"
    # else
        # loginfo "\e[1m\e[92m  --> ${SOFT} is not installed!\e[0m"
    fi
done

# Checking if the softwares which were planned to be installed are present on the system:
loginfo "\e[1m\e[36m  --> Checking install list!\e[0m"
N_LINES=$(wc -l < temp/willBeInstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeInstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
    else
        # Metapackages don't validate the previous test
        dpkg-query -s ${SOFT} > /dev/null 2> /dev/null
        if [ $? == 0 ]; then
            loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
        else
            # Definitively not installed!
            loginfo "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mMissing\e[0m]"
        fi
    fi
done



# Cleaning folder:
# =========================================================
loginfo ""
loginfo "\e[1m\e[32m==> \e[1m\e[37mCleaning folder:\e[0m"
rm -rf temp/ 2>>${LOGFILE}
if [ $? == 0 ]; then
    loginfo "\e[1m\e[92m  --> Done!\e[0m"
else
    loginfo "\e[1m\e[31m  --> Error!\e[0m"
fi



# End of the script:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
loginfo "\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m"
echo -e "  \e[4m\e[94m--> See ${LOGFILE} for more informations\e[0m"



# Reboot:
# =========================================================
echo ""
read -p "Take some time to save your work, then press ENTER to restart the system!"
reboot
