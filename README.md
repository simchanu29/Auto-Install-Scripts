# Auto-Install-Scripts
![Status](https://img.shields.io/badge/Status-In%20Development-red.svg)
![Distrib](https://img.shields.io/badge/Ubuntu-16.04-brightgreen.svg)

The aim of this project is to have a script capable of providing the first system upgraade and install a pre-defined list of softwares. 
In the end, this script will also take a list of softwares you want to uninstall (usually pre-installed softwares are just a waste of space, so this will automate their uninstallation) and provide minor configurations for softwares installed (ie: deactivate root account for ssh connections,...).
See actual CHANGELOG for the list of implemented features.

## Installation
### First step
Install git:

```sudo apt update && sudo apt install git```

### Second step
Clone this repository:

```git clone https://github.com/fcebron/Auto-Install-Scripts.git```

### Third step
Launch the script in super-user mode:

```cd Auto-Install-Scripts```

```chmod +x autoInstall.sh```

```sudo ./autoInstall.sh```
