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



# Color list
# =========================================================
# list on https://misc.flogisoft.com/bash/tip_colors_and_formatting
BOL="\e[1m"
BLI="\e[5m"
GRE="\e[32m"
LGR="\e[92m"
CYA="\e[36m"
GRA="\e[37m"
RED="\e[31m"
LYE="\e[93m"
LBL="\e[94m"
END="\e[0m"



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
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Checking if root:${END}"
if [ "$EUID" -ne 0 ]; then
    loginfo "${RED}  --> You need to run this program as root:${END}"
    loginfo "    sudo ./autoInstall.sh"
    loginfo "${RED}  --> Exiting program! ${END}"
    exit
else
    loginfo "${BOL}${LGR}  --> Done! ${END}"
fi



# Checking the internet connection:
# =========================================================
echo ""
echo "" >> ${LOGFILE}
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Checking if the computer is connected to the internet:${END}"

CONNECTION=$(ping -q -c 2 www.ubuntu.com > /dev/null && echo 0 || echo 1)
if [ ${CONNECTION} -eq 0 ]; then
    loginfo "${BOL}${LGR}  --> Connected to the internet! ${END}"
else
    loginfo "${BOL}${RED}  --> Not connected to the internet! ${END}"
    loginfo "${BOL}${RED}  --> Exiting program! ${END}"
    exit 0
fi



# Adding Canonical's partner repository:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Adding Canonical's partner repository:${END}"
sed -i.bak "/^# deb .*partner/ s/^# //" /etc/apt/sources.list 2>> ${LOGFILE}
if [ $? == 0 ]; then
    loginfo "${BOL}${LGR}  --> Done! ${END}"
else
    loginfo "${BOL}${RED}  --> Error! ${END}"
fi



# Checking if aptitude is already present in the system:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Checking Aptitude:${END}"
if hash aptitude 2>/dev/null; then
    loginfo "${BOL}${LGR}  --> aptitude is already installed! ${END}"
else
    # Install aptitude for futures installations:
    loginfo "${BOL}${RED}  --> aptitude is not installed! ${END}"
    loginfo ""
    loginfo "${BOL}${GRE}==> ${BOL}${GRA}Installing Aptitude:${END}"
    apt update 2>> ${LOGFILE}
    apt install -y aptitude 2>> ${LOGFILE}
    if [ $? == 0 ]; then
        loginfo "${BOL}${LGR}  --> Aptitude installed! ${END}"
    else
        loginfo "${BOL}${RED}  --> Error! Exiting! ${END}"
        exit
    fi
fi

echo ""
echo ""
echo -e "\t\e[94m##################################################"
echo -e "\t##                                              ##"
echo -e "\t##     The following steps could be long${BLI}...${END}${LBL}     ##"
echo -e "\t##     --> It is time to take a break/${BLI}${LYE}coffee${END}${LBL}    ##"
echo -e "\t##                                              ##"
echo -e "\t##################################################${END}"
echo ""


# Parsing software list:
# =========================================================
echo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Parsing software list:${END}"
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
# loginfo "${BOL}${CYA}  --> Will be removed:${END}"
# loginfo "${BOL}${RED}      ${UNINSTALL_LIST}${END}\n"
# loginfo "${BOL}${CYA}  --> Will be installed:${END}"
# loginfo "${BOL}${LGR}      ${INSTALL_LIST}${END}"
if [ $? == 0 ]; then
        loginfo "${BOL}${LGR}  --> Done! ${END}"
    else
        loginfo "${BOL}${RED}  --> Error! ${END}"
        exit
    fi



# Removing un-wanted softwares:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Removing un-wanted softwares:${END}"

# Emptying "temp.txt":
echo -n > ${TEMPFILE1}

# Checking if the softwares that are planned to be uninstalled are already present on the system:
loginfo "${BOL}${CYA}  --> Checking the system! ${END}"
N_LINES=$(wc -l < temp/willBeUninstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeUninstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        echo ${SOFT} >> ${TEMPFILE1}
        loginfo "${BOL}${END}\t\t${SOFT}\t\t[${RED}Installed${END}]"
    # else
        # loginfo "${BOL}${LGR}  --> ${SOFT} is not installed! ${END}"
    fi
done
UNINSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' ${TEMPFILE1})
if [ -s ${TEMPFILE1} ]
then
    loginfo "${BOL}${CYA}  --> Will be removed:${END}"
    loginfo "${BOL}${RED}      ${UNINSTALL_LIST}${END}"
    sudo aptitude purge -y $UNINSTALL_LIST 2>> ${LOGFILE}
else
    loginfo "${BOL}${LGR}  --> Nothing will be removed! ${END}"
fi



# Update and Upgrade system:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Updating full system:${END}"
aptitude update 2>> ${LOGFILE}
if [ $? == 0 ]; then
    loginfo "${BOL}${LGR}  --> Update Done! ${END}"
else
    loginfo "${BOL}${RED}  --> Update Error! ${END}"
fi

aptitude full-upgrade -y 2>> ${LOGFILE}
# aptitude safe-upgrade -y 2>> ${LOGFILE}  # In case of issues with full-upgrade
if [ $? == 0 ]; then
    loginfo "${BOL}${LGR}  --> Upgrade Done! ${END}"
else
    loginfo "${BOL}${RED}  --> Update Error! ${END}"
fi



# Installing Softwares:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Installing Softwares:${END}"

# Emptying "temp.txt":
echo -n > ${TEMPFILE1}

# Checking if the softwares that are planned to be installed are already present on the system:
loginfo "${BOL}${CYA}  --> Checking the system! ${END}"
N_LINES=$(wc -l < temp/willBeInstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeInstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        loginfo "${BOL}${END}\t\t${SOFT}\t\t[${LGR}Installed${END}]"
    else
        # Metapackages don't validate the previous test
        dpkg-query -s ${SOFT} > /dev/null 2> /dev/null
        if [ $? == 0 ]; then
            loginfo "${BOL}${END}\t\t${SOFT}\t\t[${LGR}Installed${END}]"
        else
            # Definitively not installed!
            echo ${SOFT} >> ${TEMPFILE1}
            loginfo "${BOL}${END}\t\t${SOFT}\t\t[${RED}Missing${END}]"
        fi
    fi
done

INSTALL_LIST=$(sed ':a;N;$!ba;s/\n/ /g' ${TEMPFILE1})
if [ -s ${TEMPFILE1} ]
then
    loginfo "${BOL}${CYA}  --> Will be installed:${END}"
    loginfo "${BOL}${LGR}      ${INSTALL_LIST}${END}"
    sudo aptitude install -y $INSTALL_LIST 2>> ${LOGFILE}
else
    loginfo "${BOL}${LGR}  --> Nothing will be installed! ${END}"
fi



# Removing old dependencies which could have been forgotten:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Removing old dependencies which could have been forgotten:${END}"
apt autoremove 2>> ${LOGFILE}
if [ $? == 0 ]; then
    loginfo "${BOL}${LGR}  --> Done! ${END}"
else
    loginfo "${BOL}${RED}  --> Error! ${END}"
fi



# Summary:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Summary:${END}"

# Checking if the softwares which were planned to be uninstalled are still present on the system:
loginfo "${BOL}${CYA}  --> Checking uninstall list! ${END}"
N_LINES=$(wc -l < temp/willBeUninstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeUninstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        loginfo "${BOL}${END}\t\t${SOFT}\t\t[${RED}Present${END}]"
    # else
        # loginfo "${BOL}${LGR}  --> ${SOFT} is not installed! ${END}"
    fi
done

# Checking if the softwares which were planned to be installed are present on the system:
loginfo "${BOL}${CYA}  --> Checking install list! ${END}"
N_LINES=$(wc -l < temp/willBeInstalled.txt)
for ((i=1; i<=${N_LINES}; i++))
do
    SOFT=$(sed "${i}q;d" temp/willBeInstalled.txt)
    if hash ${SOFT} 2>/dev/null; then
        loginfo "${BOL}${END}\t\t${SOFT}\t\t[${LGR}Installed${END}]"
    else
        # Metapackages don't validate the previous test
        dpkg-query -s ${SOFT} > /dev/null 2> /dev/null
        if [ $? == 0 ]; then
            loginfo "${BOL}${END}\t\t${SOFT}\t\t[${LGR}Installed${END}]"
        else
            # Definitively not installed!
            loginfo "${BOL}${END}\t\t${SOFT}\t\t[${RED}Missing${END}]"
        fi
    fi
done



# Cleaning folder:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}Cleaning folder:${END}"
rm -rf temp/ 2>>${LOGFILE}
if [ $? == 0 ]; then
    loginfo "${BOL}${LGR}  --> Done! ${END}"
else
    loginfo "${BOL}${RED}  --> Error! ${END}"
fi



# End of the script:
# =========================================================
loginfo ""
loginfo "${BOL}${GRE}==> ${BOL}${GRA}End of the script! ${END}"
echo -e "  \e[4m\e[94m--> See ${LOGFILE} for more informations${END}"



# Reboot:
# =========================================================
echo ""
read -p "Take some time to save your work, then press ENTER to restart the system!"
reboot
