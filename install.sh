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
##      Version 3.3.0 2023-5-17    ##
#####################################

# This script will download and install the printcfg package from GitHub.
# Run the following:
# curl -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/rootiest/printcfg/master/install.sh | bash

# Set the owner and repo name
owner="rootiest"
repo="printcfg"

# Define the klipper config file
printer=~/printer_data/config/printer.cfg

# Check if the repo exists
if ! git ls-remote https://github.com/"$owner"/"$repo" >/dev/null; then
    echo "The repo does not exist."
    exit 1
fi

# Change to the home directory
cd ~

# Check if printcfg is already installed
if [ -d ~/printcfg ]; 
then
    echo "printcfg is already installed."
else
    echo "Installing printcfg..."
    # Clone the repo
    git clone https://github.com/"$owner"/"$repo"
    # Check if the repo was cloned
    if [ ! -d ~/printcfg ]; then
        echo "Error: Repo not cloned."
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

# Check if the file exists
if [ ! -f "$printer" ]
then
    echo "Error: File '$printer' not found."
    echo "Please make sure you have klipper installed and your config is located in $printer"
    exit 1
fi

# Check if the config already contains the printcfg config
if grep -q "[include printcfg/*]" "$printer"
then
    echo "printcfg config already included."
else
    echo "Adding printcfg config to $printer..."
    # Add printcfg config to beginning of file
    sed -i '1s/^/[include printcfg\/print_config.cfg]\n/' "$printer"
fi

# Check if link already exists
if [ ! -L ~/printer_data/config/printcfg ]
then
    # Link printcfg to the printer config directory
    echo "Linking printcfg to the printer config directory..."
    ln -s ~/printcfg ~/printer_data/config/printcfg
    # Check if the link was created
    if [ ! -L ~/printer_data/config/printcfg ]
    then
        echo "Error: Link not created."
        exit 1
    fi
else
    echo "Link already exists."
fi

# Perform all checks to make sure printcfg is installed correctly
echo "Checking printcfg installation..."

# Check if the repo exists
if [ ! -d ~/printcfg ]; then
    echo "Error: Repo not cloned."
    exit 1
fi

# Check if the printer.cfg exists
if [ ! -f "$printer" ]
then
    echo "Error: File '$printer' not found."
    echo "Please make sure you have klipper installed and your config is located in $printer"
    exit 1
fi

# Check if printcfg is included in the printer.cfg file
if grep -q "[include printcfg/*]" "$printer";
then

else
    echo "Error: printcfg config not included in $printer"
    exit 1
fi

# Check if link exists
if [ ! -L ~/printer_data/config/printcfg ]
then
    echo "Error: Link not created."
    exit 1
fi

# Acknowledge that the installation checks passed
echo "printcfg installation checks passed."

# Success!
echo "Printcfg has been successfully downloaded and installed."
