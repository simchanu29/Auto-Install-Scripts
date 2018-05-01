# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
- [ ] Check before installation of removal if the software is already present on the system, to optimize the program.
- [ ] Check before exiting the program if all desired softwares have been installed.
- [ ] Specific installation of softwares which are not in the distribution's repositories.
- [ ] Add Debian support.
- [ ] Add Archlinux support.
- [ ] Add Fedora support.
- [ ] GUI for selecting softwares to install.


## [0.2.0](https://github.com/fcebron/Auto-Install-Scripts/releases/tag/v0.2.0) - 2018-05-01
### Added
- Test the internet connection with a ping to exit the program faster in case that there is no connection.
- Root check before executing full program.
- Parsing the .md file containing a list of software to install.
- Installation of the list of software.
- Suppression of selected pre-installed softwares before full-upgrade (to save some time, bandwidth,...).


## [0.1.0] - 2018-04-28
### Added
- Automatic detection and installation (if missing) of Aptitude.
- Adding Canonical's partner repository to the system.
- Full Upgrade of the system.
- Coloured output of this script.
- Dated logfile of each installation.
- Tutorial explaining how to use this script.
