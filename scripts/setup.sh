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
##      Version 4.0.0 2023-6-5     ##
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
repo="printcfg"
# Get home directory
home=$(eval echo ~"$USER")
# Define the klipper config file
config=$home/printer_data/config
# Define the printer.cfg and moonraker.conf files
printer=$home/printer_data/config/printer.cfg
# Set the default profile
default_src=default
user_vars=$config/user_profile.cfg
old_user_vars=$config/$repo/user_profile.cfg
user_cfg=$config/user_config.cfg
old_user_cfg=$config/$repo/user_config.cfg

LOGFILE="$home/$repo/logs/setup.log"
exec 3>&1 1>"$LOGFILE" 2>&1
trap "echo 'ERROR: An error occurred during execution, check log for details.' >&3" ERR
trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG

# Check if any parameters were provided
if [ $# -eq 0 ]
then
    src_cfg=$config/$repo/profiles/$default_src/config.cfg
    src_vars=$config/$repo/profiles/$default_src/variables.cfg
    src_path=$config/$repo/profiles/$default_src
    profile_used=$default_src
else
    # Set the src_vars file
    if [ -n "$1" ]
    then
        src_cfg=$config/$repo/profiles/$1/config.cfg
        src_vars=$config/$repo/profiles/$1/variables.cfg
        src_path=$config/$repo/profiles/$1
        profile_used=$1
    fi
fi

echo "Checking $repo executable..."
# Check if bin exists
if [ ! -f /usr/local/bin/$repo ]
then
    echo "Creating $repo bin..." >&3
    sudo ln -s "$home"/$repo/src/$repo.py /usr/local/bin/$repo
    sudo chmod +x /usr/local/bin/$repo
    echo -e "\e[32m$repo bin created successfully.\e[0m" >&3
else
    # Check if bin is executable
    if [ ! -x /usr/local/bin/$repo ]
    then
        echo "Making $repo bin executable..." >&3
        sudo chmod +x /usr/local/bin/$repo
        echo -e "\e[32m$repo bin made executable.\e[0m" >&3
    else
        echo -e "\e[32m$repo bin is up to date.\e[0m" >&3
    fi
fi

# Check for force parameter
if [ "$2" == "force" ]
then
    echo -e "\e[31mChanging user profile to $default_src.\e[0m" >&3
    echo
    echo "Updating user config..." >&3
    # Check if src_cfg exists
    if [ -f "$src_cfg" ]
    then
        # Check if user config exists
        if [ -f "$user_cfg" ]
        then
            # Remove old user config
            rm "$user_cfg"
            # Verify removal was successful
            if [ ! -f "$user_cfg" ]
            then
                echo "Old user config removed." >&3
                # Copy new user config
                cp "$src_cfg" "$user_cfg"
                # Verify copy was successful
                if [ -f "$user_cfg" ]
                then
                    echo "New user config copied."
                    # User config is up to date
                    echo -e "\e[32mUser config is now up to date.\e[0m" >&3
                else
                    echo -e "\e[31mUser config copy failed.\e[0m" >&3
                    exit 1
                fi
            else
                echo -e "\e[31mOld user config removal failed.\e[0m" >&3
                exit 1
            fi
        else
            echo -e "\e[31mUser config does not exist.\e[0m" >&3
            exit 1
        fi
    else
        echo -e "\e[31mSource config does not exist.\e[0m" >&3
        exit 1
    fi
    # Check if src_vars exists
    if [ -f "$src_vars" ]
    then
        # Check if user vars exists
        if [ -f "$user_vars" ]
        then
            # Remove old user vars
            rm "$user_vars"
            # Verify removal was successful
            if [ ! -f "$user_vars" ]
            then
                echo "Old user vars removed."
                # Copy new user vars
                cp "$src_vars" "$user_vars"
                # Verify copy was successful
                if [ -f "$user_vars" ]
                then
                    echo "New user vars copied."
                    # User vars is up to date
                    echo -e "\e[32mUser vars is now up to date.\e[0m" >&3
                else
                    echo -e "\e[31mUser vars copy failed.\e[0m" >&3
                    exit 1
                fi
            else
                echo -e "\e[31mOld user vars removal failed.\e[0m" >&3
                exit 1
            fi
        else
            echo -e "\e[31mUser vars does not exist.\e[0m" >&3
            exit 1
        fi
    else
        echo -e "\e[31mSource vars does not exist.\e[0m" >&3
        exit 1
    fi
else
    echo "Checking user config..." >&3
    # Check that user config exists
    if [ ! -f "$user_cfg" ]
    then
        # Check if old user config exists
        if [ -f "$old_user_cfg" ]
        then
            echo -e "\e[31mUser config location is out of date.\e[0m" >&3
            mv "$old_user_cfg" "$user_cfg"
            # Verify move was successful
            if [ -f "$user_cfg" ]
            then
                echo "User config moved to $config/user_config.cfg" >&3
            else
                echo -e "\e[31mUser config move failed.\e[0m" >&3
                exit 1
            fi
            # Check if old include line exists in printer.cfg
            echo "Checking printer.cfg include line..." >&3
            if grep -qFx "[include $repo/user_config.cfg]" "$printer"
            then
                echo -e "\e[31mInclude line is out of date.\e[0m" >&3
                # Remove old include line
                sed -i "/\[include $repo\/user_config.cfg\]/d" "$printer"
                # Add new include line
                sed -i "1s/^/[include user_config.cfg]\n/" "$printer"
                # Verify include line was added
                if grep -qFx "[include user_config.cfg]" "$printer"
                then
                    echo "Include line updated." >&3
                    # User config is up to date
                    echo -e "\e[32mUser config is now up to date.\e[0m" >&3
                else
                    echo -e "\e[31mInclude line update failed.\e[0m" >&3
                    exit 1
                fi
            else
                if grep -qFx "[include user_config.cfg]" "$printer"
                then
                    echo -e "\e[32mUser config is up to date.\e[0m" >&3
                else
                    echo -e "\e[31mInclude line does not exist.\e[0m" >&3
                    exit 1
                fi
            fi
        else
            echo -e "\e[31mUser config does not exist.\e[0m" >&3
            exit 1
        fi
    else
        # User config is up to date
        echo -e "\e[32mUser config is up to date.\e[0m" >&3
    fi
    
    echo >&3
    echo "Checking user profile..." >&3
    
    # Check that user profile exists
    if [ ! -f "$user_vars" ]
    then
        # Check if old user profile exists
        if [ -f "$old_user_vars" ]
        then
            echo -e "\e[31mUser profile location is out of date.\e[0m" >&3
            mv "$old_user_vars" "$user_vars"
            # Verify move was successful
            if [ -f "$user_vars" ]
            then
                echo "User profile moved to $config/user_profile.cfg" >&3
            else
                echo -e "\e[31mUser profile move failed.\e[0m" >&3
                exit 1
            fi
        else
            echo -e "\e[31mUser profile does not exist.\e[0m" >&3
            exit 1
        fi
    fi
    
    # Find version of user profile
    user_vars_version=$(grep -oP '(variable_version: ).*' "$user_vars")
    user_vars_version=${user_vars_version#variable_version: }
    src_vars_version=$(grep -oP '(variable_version: ).*' "$src_vars")
    src_vars_version=${src_vars_version#variable_version: }
    #user_vars_version=$(python3 "$home"/$repo/src/find_string.py "variable_version: " "$user_vars")
    #src_vars_version=$(python3 "$home"/$repo/src/find_string.py "variable_version: " "$src_vars")
    
    # Check if user profile is up to date
    
    if [ "$user_vars_version" != "$src_vars_version" ]; then
        echo >&3
        echo -e "\e[31mUser profile is not up to date.\e[0m" >&3
        echo "User profile:   $profile_used" >&3
        echo "User version:   $user_vars_version" >&3
        echo "Source version: $src_vars_version" >&3
        echo >&3
        echo -e "\033[1;31mVersion mismatch: [$user_vars]\e[0m" >&3
        echo >&3
        echo "Attempting to patch user profile..." >&3
        echo >&3
        if [ -f "$src_path"/patch_notes.txt ]; then
            echo -e "\e[31mPatch notes:" >&3
            cat "$src_path"/patch_notes.txt
            echo -e "\e[0m" >&3
        fi
        echo >&3
        bash "$home"/$repo/scripts/patch.sh
        exit 1
    else
        echo -e "\e[32mUser profile is up to date.\e[0m" >&3
        echo "User profile:   $profile_used" >&3
        echo "Profile version:   $user_vars_version" >&3
    fi
fi

# Check that printcfg.conf exists
echo >&3
echo "Checking $repo config..." >&3
$repo_conf="$home"/$repo/$repo.conf
if [ ! -f "$repo_conf" ]
then
    echo -e "\e[31m$repo_conf does not exist.\e[0m" >&3
    exit 1
else
    echo -e "\e[32m$repo config: $repo_conf\e[0m" >&3
fi

# Check that printcfg service is enabled
echo >&3
echo "Checking $repo service..." >&3
if systemctl is-enabled $repo.service | grep -q "enabled"
then
    # Check if printcfg service is running
    if systemctl is-active $repo.service | grep -q "active"
    then
        echo -e "\e[32m$repo service is active.\e[0m" >&3
    else
        echo -e "\e[31m$repo service is not running.\e[0m" >&3
        exit 1
    fi
else
    echo -e "\e[31m$repo service is not enabled.\e[0m" >&3
    exit 1
fi

echo >&3
exit 0