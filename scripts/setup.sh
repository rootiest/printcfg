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
user_vars=$config/$repo/user_profile.cfg

# Check if any parameters were provided
if [ $# -eq 0 ]
then
    src_vars=$config/$repo/profiles/$default_src/variables.cfg
else
    # Set the src_vars file
    if [ -n "$1" ]
    then
        src_vars=$config/$repo/profiles/$1/variables.cfg
    fi
fi

echo "Checking user profile..."

# Check that user profile exists
if [ ! -f $user_vars ]; then
    echo -e "\e[31mUser profile does not exist.\e[0m"
    exit 1
fi

# Find version of user profile
user_vars_version=$(grep -oP '(variable_version: ).*' $user_vars)
user_vars_version=${user_vars_version#variable_version: }
src_vars_version=$(grep -oP '(variable_version: ).*' $src_vars)
src_vars_version=${src_vars_version#variable_version: }

# Check if user profile is up to date
if [ "$user_vars_version" != "$src_vars_version" ]; then
    echo -e "\e[31mUser profile is not up to date.\e[0m"
    echo "User version:   $user_vars_version"
    echo "Source version: $src_vars_version"
    echo -e "\e[31mPlease update the user profile.\e[0m"
    echo
    echo -e "\e[31mSetup checks failed.\e[0m"
        if [ -n "$2" ]
    then
        # If second argument is "force"
        if [ "$2" == "force" ]
        then
            # Fix the user profile
            echo "Fixing user profile..."
            cp $src_vars $user_vars
            echo "User profile fixed."
            echo
        fi
    else
        echo
        echo -e "\e[31mUser profile is not up to date.\e[0m"
        echo
        echo
        echo "To force update, run setup.sh with the following arguments:"
        echo "The first argument set to the profile you want to use."
        echo "The second argument set to \"force\"."
        echo "Example: ~/$repo/scripts/setup.sh default force"
        echo
        echo -e "\e[31mNOTE:\e[0m"
        echo -e "\e[31mThis will overwrite any changes you have made to the user profile.\e[0m"
        echo
        echo -e "\e[33mOtherwise, please update the user profile manually following the changelog.\e[0m"
        echo
        echo -e "\e[31mUser profile is not up to date.\e[0m"
        echo "User version:   $user_vars_version"
        echo "Source version: $src_vars_version"
        exit 1
    fi
    
    echo -e "\e[32mUser profile is up to date.\e[0m"
    echo "User version:   $user_vars_version"
    echo
fi