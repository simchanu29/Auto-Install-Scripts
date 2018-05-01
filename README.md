# Auto-Install-Scripts
![Status](https://img.shields.io/badge/Status-In%20Development-red.svg)
![Distrib](https://img.shields.io/badge/Ubuntu-16.04-brightgreen.svg)
[![Vaadin Directory](https://img.shields.io/vaadin-directory/v/vaadinvaadin-grid.svg)](https://github.com/fcebron/Auto-Install-Scripts/releases/tag/v0.2.0)

The aim of this project is to have a script capable of providing the first system upgrade and install a pre-defined [list of softwares](SoftwareList.md). This program is design to be easily customisable.

In the end, this script will also take a list of softwares you want to uninstall (usually pre-installed softwares are just a waste of space, so this will automate their uninstallation) and provide minor configurations for softwares installed (ie: deactivate root account for ssh connections,...).

See actual [CHANGELOG](CHANGELOG.md) for the list of implemented features.

## Installation
### Git installation
Install git:

```sudo apt update && sudo apt install git```

Clone this repository:

```git clone https://github.com/fcebron/Auto-Install-Scripts.git```

Launch the script in super-user mode:

```cd Auto-Install-Scripts && chmod +x autoInstall.sh```

```sudo ./autoInstall.sh```

### Wget installation
Download and extract the latest version (chose between the 2 following ways to do so):

- Zip file: ```wget https://github.com/fcebron/Auto-Install-Scripts/archive/v0.1.0.zip && unzip v0.1.0.zip```
- Tar.gz file : ```wget https://github.com/fcebron/Auto-Install-Scripts/archive/v0.1.0.tar.gz && tar zxvf v0.1.0.tar.gz```

Launch the script in super-user mode:

```cd Auto-Install-Scripts && chmod +x autoInstall.sh```

```sudo ./autoInstall.sh```
