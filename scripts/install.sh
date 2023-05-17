#!/bin/bash
# Copyright (C) 2023 Chris Laprade (chris@rootiest.com)
# 
# This file is part of Hephaestus.
# 
# Hephaestus is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Hephaestus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Hephaestus.  If not, see <http://www.gnu.org/licenses/>.

#####################################
##      Printcfg Install Script    ##
##      Version 3.5.0 2023-5-17    ##
#####################################

# This script will download and install the printcfg package from GitHub.
# Run the following:
# curl https://raw.githubusercontent.com/rootiest/printcfg/master/scripts/install.sh | bash

# Set the owner and repo name
owner="rootiest"
repo="printcfg"

# Define the klipper config file
config=~/printer_data/config
printer=~/printer_data/config/printer.cfg
moonraker=~/printer_data/config/moonraker.conf

# Welcome message
echo "Welcome to the printcfg install script."
echo "This script will download and install the printcfg package from GitHub."

echo
echo "Installing printcfg..."

# Check if the repo exists
if ! git ls-remote https://github.com/"$owner"/"$repo" >/dev/null; then
    echo "The repo does not exist."
    exit 1
fi

# Change to the home directory
cd ~

# Check if printcfg is already installed
if [ -d ~/$repo ]; 
then
    echo -e "\e[33mprintcfg repo is already installed.\e[0m"
else
    echo "Installing printcfg repo..."
    # Clone the repo
    git clone https://github.com/"$owner"/"$repo"
    # Check if the repo was cloned
    if [ ! -d ~/$repo ]; then
        echo -e "\e[31mError: Repo not cloned.\e[0m"
        exit 1
    else
        echo "Repo cloned successfully."
    fi
fi

# Change to the repo directory
cd "$repo"

### Run any setup scripts ###

# Install the dependencies
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# Run the setup script
if [ -f setup.py ]; then
    python setup.py install
fi

### Install into klippers config ###

# Check if config directory exists
if [ ! -d "$config" ]
then
    echo -e "\e[31mError: Directory '$config' not found.\e[0m"
    echo "Please make sure you have klipper installed and your config is located in $config"
    exit 1
fi

# Check if the file exists
if [ ! -f "$printer" ]
then
    echo -e "\e[31mError: File '$printer' not found.\e[0m"
    echo "Please make sure you have klipper installed and your config is located in $printer"
    exit 1
fi

# Check if user variables file exists
if [ ! -f ~/$repo/print_variables.cfg ]
then
    # Copy printcfg variables to config directory
    echo "Copying user variables to config directory..."
    cp -r ~/$repo/src/src_variables.cfg ~/$repo/print_variables.cfg
else
    echo -e "\e[33mUser variables already exist.\e[0m"
fi

# Check if link already exists
if [ ! -L $config/$repo ]
then
    # Link printcfg to the printer config directory
    echo "Linking printcfg to the printer config directory..."
    ln -s ~/$repo $config/printcfg
    # Check if the link was created
    if [ ! -L $config/$repo ]
    then
        echo -e "\e[31mError: Link not created.\e[0m"
        exit 1
    fi
else
    echo -e "\e[33mprintcfg symlink already exists.\e[0m"
fi

# Check if include line exists in printer.cfg
if grep -qFx "[include printcfg/print_config.cfg]" "$printer"
then
    echo -e "\e[33mprintcfg config already included.\e[0m"
else
    echo "Adding printcfg config to $printer..."
    # Add printcfg config to beginning of file
    sed -i '1s/^/[include printcfg\/print_config.cfg]\n/' "$printer"
fi

# Check if include line exists in moonraker.conf
if [ ! -f "$moonraker" ]
then
    echo -e "\e[31mError: File '$moonraker' not found.\e[0m"
    echo "Please make sure you have moonraker installed and your config is located in $moonraker"
    exit 1
fi

# Check if the moonraker config already contains printcfg config
if grep -qFx "[include printcfg/moonraker-printcfg.conf]" "$moonraker"
then
    echo -e "\e[33mprintcfg moonraker already included.\e[0m"
else
    echo "Adding printcfg config to $moonraker..."
    # Add printcfg config to beginning of file
    sed -i '1s/^/[include printcfg\/moonraker-printcfg.conf]\n/' "$moonraker"
fi

echo "Install complete."
echo 

# Perform all checks to make sure printcfg is installed correctly
echo "Checking printcfg installation..."

# Check if the repo exists
if [ ! -d ~/$repo ]; then
    echo -e "\e[31mError: Repo not cloned.\e[0m"
    exit 1
fi

# Check if the printer.cfg exists
if [ ! -f "$printer" ]
then
    echo -e "\e[31mError: File '$printer' not found.\e[0m"
    echo "Please make sure you have klipper installed and your config is located in $printer"
    exit 1
fi

# Check if moonraker config exists
if [ ! -f "$moonraker" ]
then
    echo -e "\e[31mError: File '$moonraker' not found.\e[0m"
    echo "Please make sure you have moonraker installed and your config is located in $moonraker"
    exit 1
fi

# Check if printcfg is included in the printer.cfg file
if ! grep -qFx "[include printcfg/print_config.cfg]" "$printer"
then
    echo -e "\e[31mError: printcfg config not included in $printer\e[0m"
    exit 1
fi

# Check if the moonraker config contains printcfg config
if ! grep -qFx "[include printcfg/moonraker-printcfg.conf]" "$moonraker"
then
    echo -e "\e[31mError: printcfg config not included in $moonraker\e[0m"
    exit 1
fi

# Check if printcfg symlink exists
if [ ! -L $config/$repo ]
then
    echo -e "\e[31mError: printcfg symlink not created.\e[0m"
    exit 1
fi

# Check if user variables file exists
if [ ! -f ~/$repo/print_variables.cfg ]
then
    echo -e "\e[31mError: printcfg user variables not found.\e[0m"
    exit 1
fi

# Acknowledge that the installation checks passed
echo -e "\e[32mprintcfg installation checks passed.\e[0m"
echo

# Finalize setup
echo "Finalizing setup..."
source ~/$repo/scripts/setup.sh
cat setup.out

# Restart klipper
echo "Restarting klipper..."
systemctl restart klipper

# Restart moonraker
echo "Restarting moonraker..."
systemctl restart moonraker

# Success!
echo
echo -e "\e[32mPrintcfg has been successfully downloaded and installed.\e[0m"
