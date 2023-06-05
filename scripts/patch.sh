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
##       Printcfg Patch Script     ##
##      Version 4.0.0 2023-6-5     ##
#####################################

# This script will apply version patches to the user profile and user config.
# Arguments:
#   $1: <profile version>   (optional) (default: [unused])

####################################################################################################

# Example:
#   ./patch.sh 4.0.0
# This will force the user profile to be patched for the specified version.

# Example:
#   ./patch.sh
# This will check the user profile version and patch it if necessary.

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
# Patterns to identify profile name and version
profile_pattern="# Profile:(.*)"
patch_pattern="# Patch:(.*)"
uconfig_pattern_old="[include $repo/user_config.cfg]"
uconfig_pattern_new="[include user_config.cfg]"
ver_patch="# Patch: *"

# Check if any parameters were provided
if [ $# -eq 0 ]
then
    # Get the user profile version
    user_vars_version=$(grep -oP '(variable_version: ).*' $user_vars)
    user_vars_version=${user_vars_version#variable_version: }
else
    # Set the user profile version
    if [ -n "$1" ]
    then
        user_vars_version=$1
    fi
fi

echo "Checking user config path..."

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
        if grep -qFx "$uconfig_pattern_old" "$printer"
        then
            echo -e "\e[31mInclude line is out of date.\e[0m"
            # Replace old include line with new include line
            python3 $home/$repo/scripts/search_replace.py "$uconfig_pattern_old" "$uconfig_pattern_new" "$printer"
            # Verify include line was added
            if grep -qFx "$uconfig_pattern_new" "$printer"
            then
                echo "Include line updated."
                # User config is up to date
                echo -e "\e[32mUser config is now up to date.\e[0m"
            else
                echo -e "\e[31mInclude line update failed.\e[0m"
                exit 1
            fi
        else
            if grep -qFx "$uconfig_pattern_new" "$printer"
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
    echo -e "\e[32mUser config path is up to date.\e[0m"
fi

# Check user config profile marker
echo "Checking user config: profile..."

# Search for the profile_pattern in the user_cfg using grep
config_profile=$(grep -oP "$profile_pattern" "$user_cfg" | cut -d':' -f2)

if [ -n "$config_profile" ]; then
    echo "Profile: $config_profile"
else
    echo -e "\e[31mUser config profile marker not found.\e[0m"
    exit 1
fi

# Check user config patch version marker
echo "Checking user config: version..."

# Search for the patch pattern in the user_cfg
config_ver=$(grep -oP "$patch_pattern" "$user_cfg" | cut -d':' -f2)

if [ -n "$config_ver" ]; then
    # Extract the version number using sed
    echo "Version: $config_ver"
else
    echo -e "\e[31mUser config version marker not found.\e[0m"
    exit 1
fi

# Check user profile profile marker
echo "Checking user profile: profile..."

# Search for the profile_pattern in the user_vars using grep
vars_profile=$(grep -oP "$profile_pattern" "$user_vars" | cut -d':' -f2)

if [ -n "$vars_profile" ]; then
    echo "Profile: $vars_profile"
else
    echo -e "\e[31mUser profile profile marker not found.\e[0m"
    exit 1
fi

# Check user profile patch version marker
echo "Checking user profile: version..."

# Search for the patch pattern in the user_vars
vars_ver=$(grep -oP "$patch_pattern" "$user_vars" | cut -d':' -f2)

if [ -n "$vars_ver" ]; then
    # Extract the version number using sed
    echo "Version: $vars_ver"
else
    echo -e "\e[31mUser profile version marker not found.\e[0m"
    exit 1
fi

# Find the latest version in the patch_notes.
echo "Checking patch notes..."

# Search for the patch pattern in the patch_notes
patch_notes="$home/$repo/profiles/$vars_profile/patch_notes.txt"

# Read version from patch notes
highest_version=$(python3 $home/$repo/scripts/read_patch_notes.py "$patch_notes")

# Print the highest version number
echo "Latest patch is: $highest_version"

# Check if the user config version is the same as the highest version
if [ "$config_ver" = "$highest_version" ]; then
    echo -e "\e[32mUser config is up to date.\e[0m"
    update_config=False
else
    echo -e "\e[31mUser config is out of date.\e[0m"
    update_config=True
fi

# Check if the user profile version is the same as the highest version

if [ "$vars_ver" = "$highest_version" ]; then
    echo -e "\e[32mUser profile is up to date.\e[0m"
    update_profile=False
else
    echo -e "\e[31mUser profile is out of date.\e[0m"
    update_profile=True
fi

if [ "$update_config" = "False" ] && [ "$update_profile" = "False" ]; then
    echo -e "\e[32mUser config and profile are up to date.\e[0m"
    echo -e "\e[32mNo action required.\e[0m"
    exit 0
else
    # Search for patch files matching the user profile version
    echo "Searching for patch files..."
    vars_patch=$home/$repo/profiles/$vars_profile/patches/$highest_version/vars.patch
    config_patch=$home/$repo/profiles/$config_profile/patches/$highest_version/config.patch
    
    # Check if the config needs to be updated
    if [ "$update_config" = "True" ]; then
        # Check if the patch file exists
        if [ -f $config_patch ]; then
            echo "Patch file found."
            # Append the contents of the patch file to the user config
            echo "Applying config patch file..."
            cat $config_patch >> $user_cfg
            echo "Config patch file applied."
            # Update version number in user config
            echo "Updating version number..."
            # Replace the version number using sed
            python3 $home/$repo/scripts/search_replace.py "$ver_patch" "$ver_patch$highest_version" "$user_cfg"
            # Verify that the version number has been updated
            if grep -qFx "$ver_patch$highest_version" "$user_cfg"
            then
                echo -e "\e[32mVersion number updated.\e[0m"
            else
                echo -e "\e[31mVersion number update failed.\e[0m"
                exit 1
            fi
            echo "Version number updated."
        else
            echo -e "\e[31mConfig patch file not found.\e[0m"
            echo "Patch file: $config_patch"
            exit 1
        fi
    fi
    
    # Check if the profile needs to be updated
    if [ "$update_profile" = "True" ]; then
        # Check if the patch file exists
        if [ -f $vars_patch ]; then
            echo "Patch file found."
            # Append the contents of the patch file to the user config
            echo "Applying profile patch file..."
            # Find the line containing '# End Custom Variables #'
            vars_end=$(grep -n '# End Custom Variables #' $user_vars | cut -d':' -f1)
            # Make sure the line number is not empty
            if [ -z "$vars_end" ]; then
                echo -e "\e[31mEnd of custom variables marker not found.\e[0m"
                echo "Marker: # End Custom Variables #"
                echo
                echo "Using 'gcode:' instead."
                vars_end=$(grep -n 'gcode:' $user_vars | cut -d':' -f1)
            fi
            # Add the patch before the line
            sed -i "$vars_end r $vars_patch" $user_vars
            # Add a newline after the patch
            sed -i "$vars_end a \ " $user_vars
            echo "Profile patch file applied."
            # Update version number in user profile
            echo "Updating version number..."
            # Replace the version number using sed
            python3 $home/$repo/scripts/search_replace.py "$ver_patch" "$ver_patch$highest_version" "$user_vars"
            # Verify that the version number has been updated
            if grep -qFx "$ver_patch$highest_version" "$user_vars"
            then
                echo -e "\e[32mVersion number updated.\e[0m"
            else
                echo -e "\e[31mVersion number update failed.\e[0m"
                exit 1
            fi
        else
            echo -e "\e[31mProfile patch file not found.\e[0m"
            echo "Patch file: $vars_patch"
            exit 1
        fi
    fi
    
    # Summarize results
    echo
    echo "Summary:"
    if [ "$update_config" = "True" ]; then
        echo -e "\e[32mUser config was successfully patched.\e[0m"
        echo -e "Version: $highest_version"
    else
        echo -e "\e[32mUser config patch was not needed.\e[0m"
        echo -e "Version: $config_ver"
    fi
    if [ "$update_profile" = "True" ]; then
        echo -e "\e[32mUser profile was successfully patched.\e[0m"
        echo -e "Version: $highest_version"
    else
        echo -e "\e[32mUser profile patch was not needed.\e[0m"
        echo -e "Version: $vars_ver"
    fi
    
    echo
    echo -e "\e[32mPatching completed successfully.\e[0m"
    exit 0
    
fi

