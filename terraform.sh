#! /bin/bash


#                       Terraform
# =========================================================
# This script performs a full upgrade of the system, then
# install a pre-defined list of softwares!
#
# =========================================================


echo -e "\t##################################################"
echo -e "\t##                                              ##"
echo -e "\t##                 Terraform                    ##"
echo -e "\t##                   0.3.0                      ##"
echo -e "\t##                                              ##"
echo -e "\t##################################################"



# Generating logfile:
# =========================================================
if [ ! -d logs ]; then
    mkdir logs
fi
LOGFILE="logs/Install_"$(date '+%Y-%m-%d-%H-%M-%S')".log"
touch ${LOGFILE}



# Generating temp folder:
# =========================================================
mkdir temp
touch temp/temp.txt
TEMPFILE1=temp/temp.txt
touch temp/temp2.txt
TEMPFILE2=temp/temp2.txt



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
else
    echo -e "\e[1m\e[92m  --> Done!\e[0m"
    echo -e "\e[1m\e[92m  --> Done!\e[0m" >> ${LOGFILE}
fi



# Checking the internet connection:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking if the computer is connected to the internet:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking if the computer is connected to the internet:\e[0m" >> ${LOGFILE}

CONNECTION=$(ping -q -c 2 www.ubuntu.com > /dev/null && echo 0 || echo 1)
if [ ${CONNECTION} -eq 0 ]; then
    echo -e "\e[1m\e[92m  --> Connected to the internet!\e[0m"
    echo -e "\e[1m\e[92m  --> Connected to the internet!\e[0m" >> ${LOGFILE}
else
    echo -e "\e[1m\e[31m  --> Not connected to the internet!\e[0m"
    echo -e "\e[1m\e[31m  --> Exiting program!\e[0m"
    echo -e "\e[1m\e[31m  --> Not connected to the internet!\e[0m" >> ${LOGFILE}
    echo -e "\e[1m\e[31m  --> Exiting program!\e[0m" >> ${LOGFILE}
    exit 0
fi



# Adding Canonical's partner repository:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mAdding Canonical's partner repository:\e[0m" >> ${LOGFILE}
sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list 2>> ${LOGFILE}
if [ $? == 0 ]; then
    echo -e "\e[1m\e[92m  --> Done!\e[0m"
    echo -e "\e[1m\e[92m  --> Done!\e[0m" >> ${LOGFILE}
else
    echo -e "\e[1m\e[31m  --> Error!\e[0m"
    echo -e "\e[1m\e[31m  --> Error!\e[0m" >> ${LOGFILE}
fi



# Checking if aptitude is already present in the system:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking Aptitude:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking Aptitude:\e[0m" >> ${LOGFILE}
if hash aptitude 2>/dev/null; then
    echo -e "\e[1m\e[92m  --> aptitude is already installed!\e[0m"
    echo -e "\e[1m\e[92m  --> aptitude is already installed!\e[0m" >> ${LOGFILE}
else
    # Install aptitude for futures installations:
    echo -e "\e[1m\e[31m  --> aptitude is not installed!\e[0m"
    echo ""
    echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude:\e[0m"
    echo -e "\e[1m\e[31m  --> aptitude is not installed!\e[0m" >> ${LOGFILE}
    echo "" >> ${LOGFILE}
    echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Aptitude:\e[0m" >> ${LOGFILE}
    apt update 2>> ${LOGFILE}
    apt install -y aptitude 2>> ${LOGFILE}
    if [ $? == 0 ]; then
        echo -e "\e[1m\e[92m  --> Aptitude installed!\e[0m"
        echo -e "\e[1m\e[92m  --> Aptitude installed!\e[0m" >> ${LOGFILE}
    else
        echo -e "\e[1m\e[31m  --> Error! Exiting!\e[0m"
        echo -e "\e[1m\e[31m  --> Error! Exiting!\e[0m" >> ${LOGFILE}
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
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mParsing software list:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mParsing software list:\e[0m" >> ${LOGFILE}
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
# echo -e "\e[1m\e[36m  --> Will be removed:\e[0m"
# echo -e "\e[1m\e[31m      ${UNINSTALL_LIST}\e[0m\n"
# echo -e "\e[1m\e[36m  --> Will be removed:\e[0m" >> ${LOGFILE}
# echo -e "\e[1m\e[31m      ${UNINSTALL_LIST}\e[0m\n" >> ${LOGFILE}
# echo -e "\e[1m\e[36m  --> Will be installed:\e[0m"
# echo -e "\e[1m\e[92m      ${INSTALL_LIST}\e[0m"
# echo -e "\e[1m\e[36m  --> Will be installed:\e[0m" >> ${LOGFILE}
# echo -e "\e[1m\e[92m      ${INSTALL_LIST}\e[0m" >> ${LOGFILE}
if [ $? == 0 ]; then
        echo -e "\e[1m\e[92m  --> Done!\e[0m"
        echo -e "\e[1m\e[92m  --> Done!\e[0m" >> ${LOGFILE}
    else
        echo -e "\e[1m\e[31m  --> Error!\e[0m"
        echo -e "\e[1m\e[31m  --> Error!\e[0m" >> ${LOGFILE}
        exit
    fi



# Removing un-wanted softwares:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mRemoving un-wanted softwares:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mRemoving un-wanted softwares:\e[0m" >> ${LOGFILE}

# Emptying "temp.txt":
echo -n > ${TEMPFILE1}

# Checking if the softwares that are planned to be uninstalled are already present on the system:
echo -e "\e[1m\e[36m  --> Checking the system!\e[0m"
echo -e "\e[1m\e[36m  --> Checking the system!\e[0m" >> ${LOGFILE}
N_LINES=$(wc -l < temp/willBeUninstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeUninstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        echo ${SOFT} >> ${TEMPFILE1}
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mInstalled\e[0m]"
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mInstalled\e[0m]" >> ${LOGFILE}
    # else
        # echo -e "\e[1m\e[92m  --> ${SOFT} is not installed!\e[0m"
        # echo -e "\e[1m\e[92m  --> ${SOFT} is not installed!\e[0m" >> ${LOGFILE}
    fi
done
UNINSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' ${TEMPFILE1})
if [ -s ${TEMPFILE1} ]
then 
    echo -e "\e[1m\e[36m  --> Will be removed:\e[0m"
    echo -e "\e[1m\e[31m      ${UNINSTALL_LIST}\e[0m"
    echo -e "\e[1m\e[36m  --> Will be removed:\e[0m" >> ${LOGFILE}
    echo -e "\e[1m\e[31m      ${UNINSTALL_LIST}\e[0m" >> ${LOGFILE}
    sudo aptitude purge -y $UNINSTALL_LIST 2>> ${LOGFILE}
else
    echo -e "\e[1m\e[92m  --> Nothing will be removed!\e[0m"
    echo -e "\e[1m\e[92m  --> Nothing will be removed!\e[0m" >> ${LOGFILE}
fi



# Update and Upgrade system:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mUpdating full system:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mUpdating full system:\e[0m" >> ${LOGFILE}
aptitude update 2>> ${LOGFILE}
if [ $? == 0 ]; then
    echo -e "\e[1m\e[92m  --> Update Done!\e[0m"
    echo -e "\e[1m\e[92m  --> Update Done!\e[0m" >> ${LOGFILE}
else
    echo -e "\e[1m\e[31m  --> Update Error!\e[0m"
    echo -e "\e[1m\e[31m  --> Update Error!\e[0m" >> ${LOGFILE}
fi

aptitude full-upgrade -y 2>> ${LOGFILE}
# aptitude safe-upgrade -y 2>> ${LOGFILE}  # In case of issues with full-upgrade
if [ $? == 0 ]; then
    echo -e "\e[1m\e[92m  --> Upgrade Done!\e[0m"
    echo -e "\e[1m\e[92m  --> Upgrade Done!\e[0m" >> ${LOGFILE}
else
    echo -e "\e[1m\e[31m  --> Update Error!\e[0m"
    echo -e "\e[1m\e[31m  --> Update Error!\e[0m" >> ${LOGFILE}
fi



# Installing Softwares:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Softwares:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mInstalling Softwares:\e[0m" >> ${LOGFILE}

# Emptying "temp.txt":
echo -n > ${TEMPFILE1}

# Checking if the softwares that are planned to be installed are already present on the system:
echo -e "\e[1m\e[36m  --> Checking the system!\e[0m"
echo -e "\e[1m\e[36m  --> Checking the system!\e[0m" >> ${LOGFILE}
N_LINES=$(wc -l < temp/willBeInstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeInstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]" >> ${LOGFILE}
    else
        # Metapackages don't validate the previous test
        dpkg-query -s ${SOFT} > /dev/null 2> /dev/null
        if [ $? == 0 ]; then
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]" >> ${LOGFILE}
        else
            # Definitively not installed!
            echo ${SOFT} >> ${TEMPFILE1}
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mMissing\e[0m]"
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mMissing\e[0m]" >> ${LOGFILE}
        fi
    fi
done

INSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' ${TEMPFILE1})
if [ -s ${TEMPFILE1} ]
then 
    echo -e "\e[1m\e[36m  --> Will be installed:\e[0m"
    echo -e "\e[1m\e[92m      ${INSTALL_LIST}\e[0m"
    echo -e "\e[1m\e[36m  --> Will be installed:\e[0m" >> ${LOGFILE}
    echo -e "\e[1m\e[92m      ${INSTALL_LIST}\e[0m" >> ${LOGFILE}
    sudo aptitude install -y $INSTALL_LIST 2>> ${LOGFILE}
else
    echo -e "\e[1m\e[92m  --> Nothing will be installed!\e[0m"
    echo -e "\e[1m\e[92m  --> Nothing will be installed!\e[0m" >> ${LOGFILE}
fi



# Removing old dependencies which could have been forgotten:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mRemoving old dependencies which could have been forgotten:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mRemoving old dependencies which could have been forgotten:\e[0m" >> ${LOGFILE}
sudo apt autoremove 2>> ${LOGFILE}
if [ $? == 0 ]; then
    echo -e "\e[1m\e[92m  --> Done!\e[0m"
    echo -e "\e[1m\e[92m  --> Done!\e[0m" >> ${LOGFILE}
else
    echo -e "\e[1m\e[31m  --> Error!\e[0m"
    echo -e "\e[1m\e[31m  --> Error!\e[0m" >> ${LOGFILE}
fi



# Summary:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mSummary:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mSummary:\e[0m" >> ${LOGFILE}

# Checking if the softwares which were planned to be uninstalled are still present on the system:
echo -e "\e[1m\e[36m  --> Checking uninstall list!\e[0m"
echo -e "\e[1m\e[36m  --> Checking uninstall list!\e[0m" >> ${LOGFILE}
N_LINES=$(wc -l < temp/willBeUninstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeUninstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mPresent\e[0m]"
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mPresent\e[0m]" >> ${LOGFILE}
    # else
        # echo -e "\e[1m\e[92m  --> ${SOFT} is not installed!\e[0m"
        # echo -e "\e[1m\e[92m  --> ${SOFT} is not installed!\e[0m" >> ${LOGFILE}
    fi
done

# Checking if the softwares which were planned to be installed are present on the system:
echo -e "\e[1m\e[36m  --> Checking install list!\e[0m"
echo -e "\e[1m\e[36m  --> Checking install list!\e[0m" >> ${LOGFILE}
N_LINES=$(wc -l < temp/willBeInstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeInstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
        echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]" >> ${LOGFILE}
    else
        # Metapackages don't validate the previous test
        dpkg-query -s ${SOFT} > /dev/null 2> /dev/null
        if [ $? == 0 ]; then
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]"
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[92mInstalled\e[0m]" >> ${LOGFILE}
        else
            # Definitively not installed!
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mMissing\e[0m]"
            echo -e "\e[1m\e[0m\t\t${SOFT}\t\t[\e[31mMissing\e[0m]" >> ${LOGFILE}
        fi
    fi
done



# Cleaning folder:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mCleaning folder:\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mCleaning folder:\e[0m" >> ${LOGFILE}
rm -rf temp/ 2>>${LOGFILE}
if [ $? == 0 ]; then
    echo -e "\e[1m\e[92m  --> Done!\e[0m"
    echo -e "\e[1m\e[92m  --> Done!\e[0m" >> ${LOGFILE}
else
    echo -e "\e[1m\e[31m  --> Error!\e[0m"
    echo -e "\e[1m\e[31m  --> Error!\e[0m" >> ${LOGFILE}
fi



# End of the script:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
echo -e "\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m"
echo -e "\e[1m\e[32m==> \e[1m\e[37mEnd of the script!\e[0m" >> ${LOGFILE}
echo -e "  \e[4m\e[94m--> See ${LOGFILE} for more informations\e[0m"



# Reboot:
# =========================================================
echo ""
read -p "Take some time to save your work, then press ENTER to restart the system!"
reboot
