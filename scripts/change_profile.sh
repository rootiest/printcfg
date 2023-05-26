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
##      Printcfg Profile Change    ##
##      Version 4.0.0 2023-5-26    ##
#####################################

# This script will change the user profile to the specified profile.
# Arguments:
#   $1: <profile name> (mandatory)

####################################################################################################

# Example:
#   ./change_profile.sh default
# This will change the user profile to the default profile.

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
profile_pattern="# Profile:(.*)"

# Check if any parameters were provided
if [ $# -eq 0 ]
then
    echo -e "\n\e[31mERROR: No profile name provided.\e[0m"
    echo "Usage: ./change_profile.sh <profile name>"
    exit 1
else
    # Set the profile name
    if [ -n "$1" ]
    then
        if [ "$1" == "backup" ]
        then
            src_vars=$config/user_profile.cfg.bak
            src_cfg=$config/user_config.cfg.bak
            src_path=$config
        else
            src_vars=$config/$repo/profiles/$1/variables.cfg
            src_cfg=$config/$repo/profiles/$1/config.cfg
            src_path=$config/$repo/profiles/$1
        fi
    fi
fi

echo -e "\nChanging profile to $1..."

# Check if the profile exists
if [ ! -d "$src_path" ]
then
    echo -e "\n\e[31mERROR: Profile $1 does not exist.\e[0m"
    echo "Usage: ./change_profile.sh <profile name>"
    exit 1
fi

# Check if the profile is already active
if [ -f "$user_vars" ]
then
    # Search for the profile_pattern in the user_vars using grep
    vars_profile=$(grep -oP "$profile_pattern" "$user_vars" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$vars_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $user_vars.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Search for the profile_pattern in the src_vars using grep
    src_profile=$(grep -oP "$profile_pattern" "$src_vars" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $src_vars.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Check if the profile is already active
    if [ "$vars_profile" == "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile $1 is already active.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Check if the user config file exists
if [ -f "$user_cfg" ]
then
    # Search for the profile_pattern in the user_cfg using grep
    cfg_profile=$(grep -oP "$profile_pattern" "$user_cfg" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$cfg_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $user_cfg.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Search for the profile_pattern in the src_cfg using grep
    src_profile=$(grep -oP "$profile_pattern" "$src_cfg" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $src_cfg.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Check if the profile is already active
    if [ "$cfg_profile" == "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile $1 is already active.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Check if source file extensions end in .bak
if [ "${src_vars: -4}" == ".bak" ]
then
    # Copy them to a temp file
    cp "$src_vars" "$src_vars.tmp"
    src_vars="$src_vars.tmp"
fi
if [ "${src_cfg: -4}" == ".bak" ]
then
    # Copy them to a temp file
    cp "$src_cfg" "$src_cfg.tmp"
    src_cfg="$src_cfg.tmp"
fi

# Backup the current user profile
if [ -f "$user_vars" ]
then
    # Check if the backup already exists
    if [ -f "$user_vars.bak" ]
    then
        # Rename the backup
        cp "$user_vars.bak" "$user_vars.old"
        # Verify that the rename was successful
        if [ $? -ne 0 ]
        then
            echo -e "\n\e[31mERROR: Failed to rename $user_vars.bak to $user_vars.old.\e[0m"
            echo "Usage: ./change_profile.sh <profile name>"
            exit 1
        fi
    fi
    # Backup the current user profile
    cp "$user_vars" "$user_vars.bak"
    # Verify that the backup was successful
    if [ $? -ne 0 ]
    then
        echo -e "\n\e[31mERROR: Failed to backup $user_vars.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Backup the current user config
if [ -f "$user_cfg" ]
then
    # Check if the backup already exists
    if [ -f "$user_cfg.bak" ]
    then
        # Rename the backup
        cp "$user_cfg.bak" "$user_cfg.old"
        # Verify that the rename was successful
        if [ $? -ne 0 ]
        then
            echo -e "\n\e[31mERROR: Failed to rename $user_cfg.bak to $user_cfg.old.\e[0m"
            echo "Usage: ./change_profile.sh <profile name>"
            exit 1
        fi
    fi
    # Backup the current user config
    cp "$user_cfg" "$user_cfg.bak"
    # Verify that the backup was successful
    if [ $? -ne 0 ]
    then
        echo -e "\n\e[31mERROR: Failed to backup $user_cfg.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Apply the new profile
if [ -f "$user_vars" ]
then
    # Copy the new profile to the user profile
    cp "$src_vars" "$user_vars"
    # Verify that the copy was successful
    if [ $? -ne 0 ]
    then
        echo -e "\n\e[31mERROR: Failed to copy $src_vars to $user_vars.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Apply the new config
if [ -f "$user_cfg" ]
then
    # Copy the new config to the user config
    cp "$src_cfg" "$user_cfg"
    # Verify that the copy was successful
    if [ $? -ne 0 ]
    then
        echo -e "\n\e[31mERROR: Failed to copy $src_cfg to $user_cfg.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Check for the new profile marker in the user_vars
if [ -f "$user_vars" ]
then
    # Search for the profile_pattern in the user_vars using grep
    vars_profile=$(grep -oP "$profile_pattern" "$user_vars" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$vars_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $user_vars.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Search for the profile_pattern in the src_vars using grep
    src_profile=$(grep -oP "$profile_pattern" "$src_vars" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $src_vars.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Check if the profile is already active
    if [ "$vars_profile" != "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Failed to apply profile $1.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Check for the new profile marker in the user_cfg
if [ -f "$user_cfg" ]
then
    # Search for the profile_pattern in the user_cfg using grep
    cfg_profile=$(grep -oP "$profile_pattern" "$user_cfg" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$cfg_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $user_cfg.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Search for the profile_pattern in the src_cfg using grep
    src_profile=$(grep -oP "$profile_pattern" "$src_cfg" | cut -d':' -f2)
    # Verify that the profile marker was found
    if [ -z "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Profile marker not found in $src_cfg.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
    # Check if the profile is already active
    if [ "$cfg_profile" != "$src_profile" ]
    then
        echo -e "\n\e[31mERROR: Failed to apply profile $1.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Remove temp files

# Check if src_vars is a temp file
if [ "${src_vars: -4}" == ".tmp" ]
then
    # Remove the temp file
    rm "$src_vars"
    # Verify that the file was removed
    if [ $? -ne 0 ]
    then
        echo -e "\n\e[31mERROR: Failed to remove $src_vars.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Check if src_cfg is a temp file
if [ "${src_cfg: -4}" == ".tmp" ]
then
    # Remove the temp file
    rm "$src_cfg"
    # Verify that the file was removed
    if [ $? -ne 0 ]
    then
        echo -e "\n\e[31mERROR: Failed to remove $src_cfg.\e[0m"
        echo "Usage: ./change_profile.sh <profile name>"
        exit 1
    fi
fi

# Success
echo -e "\n\e[32mSuccessfully applied profile $1.\e[0m"
