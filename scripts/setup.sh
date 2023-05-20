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
##      Version 3.8.0 2023-5-20    ##
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
# Define the klipper config file
config=~/printer_data/config
# Define the printer.cfg and moonraker.conf files
printer=~/printer_data/config/printer.cfg
moonraker=~/printer_data/config/moonraker.conf
# Set the default profile
default_src=default
user_vars=$config/user_profile.cfg
old_user_vars=$config/$repo/user_profile.cfg
user_cfg=$config/user_config.cfg
old_user_cfg=$config/$repo/user_config.cfg

# Check if any parameters were provided
if [ $# -eq 0 ]
then
    src_vars=$config/$repo/profiles/$default_src/variables.cfg
    src_path=$config/$repo/profiles/$default_src
else
    # Set the src_vars file
    if [ -n "$1" ]
    then
        src_vars=$config/$repo/profiles/$1/variables.cfg
        src_path=$config/$repo/profiles/$1
    fi
fi

echo "Checking user profile..."

# Check that user profile exists
if [ ! -f $user_vars ]; then
    # Check if old user profile exists
    if [ -f $old_user_vars ]; then
        echo -e "\e[31mUser profile location is out of date.\e[0m"
        echo "User profile will be moved to $config/user_profile.cfg"
        mv $old_user_vars $user_vars
    else
        echo -e "\e[31mUser profile does not exist.\e[0m"
        exit 1
    fi
fi

echo "Checking user config..."

# Check that user config exists
if [ ! -f $user_cfg ]; then
    # Check if old user config exists
    if [ -f $old_user_cfg ]; then
        echo -e "\e[31mUser config location is out of date.\e[0m"
        echo "User config will be moved to $config/user_config.cfg"
        mv $old_user_cfg $user_cfg
    else
        echo -e "\e[31mUser config does not exist.\e[0m"
        exit 1
    fi
fi

# Find version of user profile
user_vars_version=$(grep -oP '(variable_version: ).*' $user_vars)
user_vars_version=${user_vars_version#variable_version: }
src_vars_version=$(grep -oP '(variable_version: ).*' $src_vars)
src_vars_version=${src_vars_version#variable_version: }

# Check if user profile is up to date
if [ "$user_vars_version" != "$src_vars_version" ]; then
    if [ -n "$2" ]
    then
        # If second argument is "force"
        if [ "$2" == "force" ]
        then
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
            echo -e "\e[31mUser profile is not up to date.\e[0m"
            echo "User version:   $user_vars_version"
            echo "Source version: $src_vars_version"
            echo -e "\e[31mPlease update the user profile.\e[0m"
            echo
            echo -e "\e[31mSetup checks failed.\e[0m"
        fi
    else
        echo
        echo -e "\e[31mUser profile is not up to date.\e[0m"
        echo
        echo -e "\033[1;31mVersion mismatch: [$user_vars]\e[0m"
        echo
        echo "To force an update, run setup.sh with the profile you want to use and the word 'force' as arguments."
        echo "For example, to force an update for the default profile, run the following command:"
        echo " ~/$repo/scripts/setup.sh default force"
        echo
        echo -e "\033[4;31mNOTE: Forcing the update will overwrite any changes you have made to the user profile.\e[0m"
        echo -e "\e[33mTo avoid this: please update the user profile manually following the patch notes.\e[0m"
        echo
        echo -e "\e[31mUser profile is not up to date.\e[0m"
        echo "User version:   $user_vars_version"
        echo "Source version: $src_vars_version"
        echo 
        echo -e "\e[31mPlease update the user profile.\e[0m"
        
        if [ -f $src_path/patch_notes.txt ]; then
            echo -e "\e[31mPatch notes:"
            cat $src_path/patch_notes.txt
            echo -e "\e[0m"
        fi
        echo -e "\033[2;101mSetup checks failed.\e[0m"
        echo
        exit 1
    fi
else
    echo -e "\e[32mUser profile is up to date.\e[0m"
    echo "User version:   $user_vars_version"
fi
