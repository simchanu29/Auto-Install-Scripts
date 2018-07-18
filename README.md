# Terraformate
![Status](https://img.shields.io/badge/Status-In%20Development-red.svg)
![Distrib](https://img.shields.io/badge/Ubuntu-16.04-brightgreen.svg)
[![Version](https://img.shields.io/badge/Version-latest%20release-yellow.svg)](https://github.com/fcebron/Terraformate/releases/latest)

The aim of this project is to have a script capable of providing the first system upgrade and install a pre-defined [list of softwares](config/SoftwareList.md). This program is design to be easily customisable.

In the end, this script will also take a list of softwares you want to uninstall (usually pre-installed softwares are just a waste of space, so this will automate their uninstallation) and provide minor configurations for softwares installed (ie: deactivate root account for ssh connections,...).

See actual [CHANGELOG](CHANGELOG.md) for the list of implemented features.

## Installation
### Git installation
Install git:

```sudo apt update && sudo apt install git```

Clone this repository:

```git clone https://github.com/fcebron/Terraformate.git```

Launch the script in super-user mode:

```cd Terraformate && chmod +x terraformate.sh```

```sudo ./terraformate.sh```

### Wget installation
Download and extract the latest version (chose between the 2 following ways to do so):

- Zip file: ```wget https://github.com/fcebron/Terraformate/releases/tag/Terraformate_0.4.0.zip && unzip Terraformate_0.4.0.zip```
- Tar.gz file : ```wget https://github.com/fcebron/Terraformate/releases/tag/Terraformate_0.4.0.tar.gz && tar zxvf Terraformate_0.4.0.tar.gz```

Launch the script in super-user mode:

```cd Terraformate && chmod +x terraformate.sh```

```sudo ./terraformate.sh```

## Help
Usage:

sudo ./terraformate.sh [-h] [-n] [-r] [-l file]

Arguments:

    -h      Help menu
    
    -n      No-reboot mode (the script will end without rebooting the computer). Warning! This argument is not compatible with the -r one.
    
    -r      Reboot mode (the script will cause the reboot of the computer). Warning! this argument is not compatible with the -n one.
    
    -l file Take file as the software list to install/uninstall. Default software list is: config/SoftwareList.md.


## Disclaimer
This script isn't compatible with snaps, because I don't use it. Don't exptect to see this feature in the upcoming versions!

This script has been tested on:
* KDE neon 5.12
