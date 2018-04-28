#! /bin/bash

# Fetch updates:
echo "=> Fetching updates"
apt update

# Install aptitude for futures installations:
echo "=> Installing Aptitude"
apt install -y aptitude

# Update and Upgrade system:
echo "Updating full system"
aptitude update
aptitude upgrade -y

echo "Completed !"
