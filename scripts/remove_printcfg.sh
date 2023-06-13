#!/bin/bash
# Copyright (C) 2023 Chris Laprade (chris@rootiest.com)
# 
# This file is part of printcfg.
# 
# printcfg is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# printcfg is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with printcfg.  If not, see <http://www.gnu.org/licenses/>.

# This script will remove printcfg from your system.

# Set the dev and repo name
dev="rootiest"
repo="printcfg"
branch="master"
# Get home directory
home=$(eval echo ~$USER)
# Define the klipper config file
config=$home/printer_data/config
# Define the printer.cfg and moonraker.conf files
printer=$home/printer_data/config/printer.cfg
moonraker=$home/printer_data/config/moonraker.conf
# Set the default profile
default_src=default
user_vars=$config/user_profile.cfg
old_user_vars=$config/$repo/user_profile.cfg
user_cfg=$config/user_config.cfg
old_user_cfg=$config/$repo/user_config.cfg

# Check if any parameters were provided
if [ "$1" ]; then
    # No parameters were provided
    # Check if the first parameter is 'force'
    if [ "$1" != "force" ]; then
        # Prompt the user to confirm
        echo -e "\e[31mWARNING: This script will remove $repo from your system.\e[0m"
        read -p "Are you sure you want to remove $repo? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            # Exit the script
            exit 1
        fi
fi

# Stop the printcfg service
sudo systemctl stop $repo.service

# Verify that the printcfg service was stopped
if [ "$(systemctl is-active $repo.service)" = "active" ]; then
    echo -e "\e[31mFailed to stop the printcfg service.\e[0m"
    exit 1
fi

# Remove the printcfg service
sudo rm /etc/systemd/system/$repo.service

# Verify that the printcfg service was removed
if [ -f /etc/systemd/system/$repo.service ]; then
    echo -e "\e[31mFailed to remove the printcfg service.\e[0m"
    exit 1
fi

# Remove the [include user_config.cfg] line from printer.cfg
include_line="[include user_config.cfg]"
replace_line="#[include user_config.cfg]"
python3 $home/$repo/scripts/search_replace.py $include_line $replace_line $printer

# Remove the printcfg directory
sudo rm -r $home/$repo

# Verify that the printcfg directory was removed
if [ -d $home/$repo ]; then
    echo -e "\e[31mFailed to remove the printcfg directory.\e[0m"
    exit 1
fi

# Remove the printcfg symlink from the klipper config directory
sudo rm $config/$repo

# Verify that the printcfg symlink was removed
if [ -L $config/$repo ]; then
    echo -e "\e[31mFailed to remove the printcfg symlink.\e[0m"
    exit 1
fi

# Success
echo -e "\e[32mSuccessfully removed $repo.\e[0m"