# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Parsing of .md file containing a list of softwares to install
- Installation of the list of softwares.
- Specific installation of softwares which are not in the distribution's repositories.
- Test the internet connection with a ping to exit the program faster in case that there is no connection.
- Suppression of selected pre-installed softwares before full-upgrade (to save some time, bandwidth,...).
- GUI for selecting softwares to install.


## [0.1.0] - 2018-04-28
### Added
- Automatic detection and installation (if missing) of Aptitude.
- Adding Canonical's partner repository to the system.
- Full Upgrade of the system.
- Colored output of this script.
- Dated logfile of each installation.
- Tutorial explaining how to use this script.
