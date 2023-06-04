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

#####################################
##      Printcfg Setup Script    ##
##      Version 4.0.0 2023-6-1     ##
#####################################

# This script will check the user profile and update it if necessary.
# Arguments:
#   $1: <profile name>  (optional) (default: default)
#   $2: force           (optional) (default: [unused])

####################################################################################################

# Example:
#   ./setup.sh default force
# This will force the user profile to be updated to the latest version.

# Example:
#   ./setup.sh default
# This will check the user profile and notify you if it is out of date.

####################################################################################################

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
if [ $# -eq 0 ]
then
    src_cfg=$config/$repo/profiles/$default_src/config.cfg
    src_vars=$config/$repo/profiles/$default_src/variables.cfg
    src_path=$config/$repo/profiles/$default_src
else
    # Set the src_vars file
    if [ -n "$1" ]
    then
        src_cfg=$config/$repo/profiles/$1/config.cfg
        src_vars=$config/$repo/profiles/$1/variables.cfg
        src_path=$config/$repo/profiles/$1
    fi
fi

echo "Checking $repo executable..."
# Check if bin exists
if [ ! -f /usr/local/bin/$repo ]
then
    echo "Creating $repo bin..."
    sudo ln -s $home/$repo/src/$repo.py /usr/local/bin/$repo
    sudo chmod +x /usr/local/bin/$repo
    echo -e "\e[32m$repo bin created successfully.\e[0m"
else
    # Check if bin is executable
    if [ ! -x /usr/local/bin/$repo ]
    then
        echo "Making $repo bin executable..."
        sudo chmod +x /usr/local/bin/$repo
        echo -e "\e[32m$repo bin made executable.\e[0m"
    else
        echo -e "\e[32m$repo bin is up to date.\e[0m"
    fi
fi

echo "Checking user config..."

# Check if second argument was provided
if [ -n "$2" ]
then
    # If second argument is "force"
    if [ "$2" == "force" ]
    then
        echo "Updating user config..."
        cp $src_cfg $user_cfg
        # update user_vars_version variable
        echo "User config updated."
        echo
    fi
else
    # Check that user config exists
    if [ ! -f $user_cfg ]
    then
        # Check if old user config exists
        if [ -f $old_user_cfg ]
        then
            echo -e "\e[31mUser config location is out of date.\e[0m"
            mv $old_user_cfg $user_cfg
            # Verify move was successful
            if [ -f $user_cfg ]
            then
                echo "User config moved to $config/user_config.cfg"
            else
                echo -e "\e[31mUser config move failed.\e[0m"
                exit 1
            fi
            # Check if old include line exists in printer.cfg
            echo "Checking printer.cfg include line..."
            if grep -qFx "[include $repo/user_config.cfg]" "$printer"
            then
                echo -e "\e[31mInclude line is out of date.\e[0m"
                # Remove old include line
                sed -i '/\[include $repo\/user_config.cfg\]/d' "$printer"
                # Add new include line
                sed -i '1s/^/[include user_config.cfg]\n/' "$printer"
                # Verify include line was added
                if grep -qFx "[include user_config.cfg]" "$printer"
                then
                    echo "Include line updated."
                    # User config is up to date
                    echo -e "\e[32mUser config is now up to date.\e[0m"
                else
                    echo -e "\e[31mInclude line update failed.\e[0m"
                    exit 1
                fi
            else
                if grep -qFx "[include user_config.cfg]" "$printer"
                then
                    echo -e "\e[32mUser config is up to date.\e[0m"
                else
                    echo -e "\e[31mInclude line does not exist.\e[0m"
                    exit 1
                fi
            fi
        else
            echo -e "\e[31mUser config does not exist.\e[0m"
            exit 1
        fi
    else
        # User config is up to date
        echo -e "\e[32mUser config is up to date.\e[0m"
    fi
fi

echo
echo "Checking user profile..."

# Check that user profile exists
if [ ! -f $user_vars ]
then
    # Check if old user profile exists
    if [ -f $old_user_vars ]
    then
        echo -e "\e[31mUser profile location is out of date.\e[0m"
        mv $old_user_vars $user_vars
        # Verify move was successful
        if [ -f $user_vars ]
        then
            echo "User profile moved to $config/user_profile.cfg"
        else
            echo -e "\e[31mUser profile move failed.\e[0m"
            exit 1
        fi
    else
        echo -e "\e[31mUser profile does not exist.\e[0m"
        exit 1
    fi
fi

# Find version of user profile
user_vars_version=$(grep -oP '(variable_version: ).*' $user_vars)
user_vars_version=${user_vars_version#variable_version: }
src_vars_version=$(grep -oP '(variable_version: ).*' $src_vars)
src_vars_version=${src_vars_version#variable_version: }

# Check if second argument was provided
if [ -n "$2" ]
then
    # If second argument is "force"
    if [ "$2" == "force" ]
    then
        echo "Updating user profile..."
        cp $src_vars $user_vars
        # update user_vars_version variable
        user_vars_version=$(grep -oP '(variable_version: ).*' $user_vars)
        user_vars_version=${user_vars_version#variable_version: }
        echo "User profile updated."
        echo
    fi
else
    # Check if user profile is up to date
    if [ "$user_vars_version" != "$src_vars_version" ]; then
        echo -e "\e[31mUser profile is not up to date.\e[0m"
        echo "User version:   $user_vars_version"
        echo "Source version: $src_vars_version"
        # Fix the user profile
        echo "Updating user profile..."
        cp $src_vars $user_vars
        # update user_vars_version variable
        user_vars_version=$(grep -oP '(variable_version: ).*' $user_vars)
        user_vars_version=${user_vars_version#variable_version: }
        echo "User profile updated."
        echo
    else
        echo
        echo -e "\e[31mUser profile is not up to date.\e[0m"
        echo "User version:   $user_vars_version"
        echo "Source version: $src_vars_version"
        echo
        echo -e "\033[1;31mVersion mismatch: [$user_vars]\e[0m"
        echo
        echo "Attempting to patch user profile..."
        echo
        if [ -f $src_path/patch_notes.txt ]; then
            echo -e "\e[31mPatch notes:"
            cat $src_path/patch_notes.txt
            echo -e "\e[0m"
        fi
        echo
        bash $home/$repo/scripts/patch.sh
        exit 1
    fi
fi

# Check that printcfg service is enabled
echo
echo "Checking $repo service..."
if systemctl is-enabled $repo.service | grep -q "enabled"
then
    # Check if printcfg service is running
    if systemctl is-active $repo.service | grep -q "active"
    then
        echo -e "\e[32m$repo service is active.\e[0m"
    else
        echo -e "\e[31m$repo service is not running.\e[0m"
        exit 1
    fi
else
    echo -e "\e[31m$repo service is not enabled.\e[0m"
    exit 1
fi

echo
exit 0