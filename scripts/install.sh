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
##      Version 3.9.0 2023-5-22    ##
#####################################

# This script will download and install the printcfg package from GitHub.
# Arguments:
#   $1: <profile name>  (optional) (default: default)
#   $2: <branch name>   (optional) (default: master)

####################################################################################################

# To install with the default profile open a terminal and run the following:

# curl https://raw.githubusercontent.com/rootiest/printcfg/master/scripts/install.sh | bash

# or to specify a profile:

# curl https://raw.githubusercontent.com/rootiest/printcfg/master/scripts/install.sh | bash -s -- default

# Substitute "default" with the name of the profile you want to install.

####################################################################################################

# List required packages
PKGLIST="git python3-pip bc"
# Set the dev and repo name
dev="rootiest"
repo="printcfg"
branch="master"
# Get home directory
home=$(eval echo ~$USER)
# Define the klipper config file
config=$home/printer_data/config
# Define the printer.cfg and moonraker.conf files
printer=$config/printer.cfg
moonraker=$config/moonraker.conf
# Set the default profile
default_src=default

# Check if any parameters were provided
if [ $# -eq 0 ]
then
    src=$default_src
else
    # Set the src file
    if [ -n "$1" ]
    then
        src="$1"
    fi
    # Set the branch
    if [ -n "$2" ]
    then
        branch="$2"
    fi
fi

# Welcome message
echo "Welcome to the printcfg install script."
echo "This script will download and install the printcfg package from GitHub."

echo
echo "Checking dependencies..."
if ! which git > /dev/null; then
    need_git=true
    echo "Missing git."
fi
if ! which pip > /dev/null; then
    need_pip=true
    echo "Missing pip."
    sudo apt-get install python3-pip
fi
if ! which bc > /dev/null; then
    need_bc=true
    echo "Missing bc."
    sudo apt-get install bc
fi
## Install missing dependencies
if [ -n "$need_git" ] || [ -n "$need_pip" ] || [ -n "$need_bc" ]; then
    echo "Installing missing dependencies..."
    sudo apt update
    sudo apt-get install -y git python3-pip bc
else
    echo -e "\e[32mAll dependencies are installed.\e[0m"
fi
echo "Installing printcfg..."

# Check if the repo exists
if ! git ls-remote https://github.com/"$dev"/"$repo" >/dev/null; then
    echo "The repo does not exist."
    exit 1
fi

# Change to the home directory
cd $home

# Check if printcfg is already installed
if [ -d $home/$repo ];
then
    echo -e "\e[33mprintcfg repo is already installed.\e[0m"
    echo "Updating printcfg repo..."
    # Change to the repo directory
    cd $home/$repo
    # Pull the latest changes
    git pull
else
    echo "Installing printcfg repo..."
    # Clone the repo
    git clone https://github.com/"$dev"/"$repo"
    # Check if the repo was cloned
    if [ ! -d $home/$repo ]; then
        echo -e "\e[31mError: Repo not cloned.\e[0m"
        exit 1
    else
        echo "Repo cloned successfully."
    fi
fi

# Change to the repo directory
cd $home/$repo

# Find the current branch
current_branch=$(git branch --show-current)

# Check if the branch was provided
if [ -n "$2" ]
then
    echo "Checking out branch $branch..."
    # Check if the branch exists
    if ! git ls-remote --heads
    then
        echo -e "\e[31mError: Branch $branch does not exist.\e[0m"
        exit 1
    fi
else
    echo "Staying on branch $current_branch..."
    branch=$current_branch
fi

# Check if the branch is already checked out
if [ "$current_branch" != "$branch" ]; then
    git switch $branch
    # Check if the branch was switched
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError: Branch not switched.\e[0m"
        exit 1
    else
        echo -e "\e[32mBranch switched successfully.\e[0m"
        pull_branch=true
    fi
else
    echo -e "\e[33mAlready on branch $branch.\e[0m"
fi

# Pull the latest changes
if [ -n "$pull_branch" ]; then
    echo "Pulling latest changes..."
    git pull
fi

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

# Check if user_config file exists
if [ ! -f $config/user_config.cfg ]
then
    # Check if profile config exists
    if [ ! -f $home/$repo/profiles/$src/config.cfg ]
    then
        echo -e "\e[31mError: Config Profile '$src' not found.\e[0m"
        echo "Using default config profile: $default_src"
        src=$default_src
    fi
    # Copy user profile to config directory
    echo -e "\e[36mUsing config profile: $src\e[0m"
    echo "Creating user_config in config directory..."
    cp -r $home/$repo/profiles/$src/config.cfg $config/user_config.cfg
else
    echo -e "\e[32mUser config already exists.\e[0m"
fi

# Check if user profile file exists
if [ ! -f $config/user_profile.cfg ]
then
    # Check if profile exists
    if [ ! -f $home/$repo/profiles/$src/variables.cfg ]
    then
        echo -e "\e[31mError: Profile '$src' not found.\e[0m"
        echo "Using default variables profile: $default_src"
        src=$default_src
    fi
    # Copy user profile to config directory
    echo -e "\e[36mUsing variables profile: $src\e[0m"
    echo "Creating user profile in config directory..."
    cp -r $home/$repo/profiles/$src/variables.cfg $config/user_profile.cfg
else
    echo -e "\e[32mUser profile already exists.\e[0m"
fi

# Check if link already exists
if [ ! -L $config/$repo ]
then
    # Link printcfg to the printer config directory
    echo "Linking printcfg to the printer config directory..."
    ln -s $home/$repo $config/printcfg
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
uconfig_pattern="[include user_config.cfg]"
if grep -qFx "$uconfig_pattern" "$printer"
then
    echo -e "\e[33mprintcfg config already included.\e[0m"
else
    echo "Adding printcfg config to $printer..."
    # Add printcfg config to beginning of file
    python3 search_replace.py "$uconfig_pattern" "$uconfig_pattern" "$printer"
fi

# Verify moonraker is installed
if [ ! -f "$moonraker" ]
then
    echo -e "\e[31mError: File '$moonraker' not found.\e[0m"
    echo "Please make sure you have moonraker installed and your config is located in $moonraker"
    exit 1
fi

# Check if the moonraker-printcfg.conf file exists
if [ ! -f $config/moonraker-printcfg.conf ]
then
    # Copy moonraker config to config directory
    echo "Creating moonraker config in config directory..."
    cp -r $home/$repo/src/mooncfg.conf $config/moonraker-printcfg.conf
else
    echo -e "\e[32mMoonraker config already exists.\e[0m"
fi

# Set branch in moonraker-printcfg.conf
echo "Setting branch in moonraker config..."
# Define search pattern
branch_pattern="primary_branch:"
# Set branch to current branch
python3 $home/$repo/scripts/search_replace.py "$branch_pattern" "$branch_pattern $branch" "$config/moonraker-printcfg.conf"

# Check if the moonraker config already contains the old printcfg config
moon_pattern="[include printcfg/moonraker-printcfg.conf]"
new_moon="[include moonraker-printcfg.conf]"

if grep -qFx "$new_moon" "$moonraker"
then
    echo -e "\e[33mprintcfg moonraker already included.\e[0m"
else
    echo "Adding printcfg config to $moonraker..."
    # Add printcfg config to moonraker
    python3 $home/$repo/scripts/search_replace.py "$moon_pattern" "$new_moon" "$moonraker"
fi

echo -e "\e[32mInstall complete.\e[0m"
echo

# Perform all checks to make sure printcfg is installed correctly
echo "Checking printcfg installation..."

# Check if the repo exists
if [ ! -d $home/$repo ]; then
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
if ! grep -qFx "$uconfig_pattern" "$printer"
then
    echo -e "\e[31mError: printcfg config not included in $printer\e[0m"
    exit 1
fi

# Check if the moonraker config contains printcfg config
if ! grep -qFx "$new_moon" "$moonraker"
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

# Check if user config exists
if [ ! -f $config/user_config.cfg ]
then
    echo -e "\e[31mError: printcfg user config not found.\e[0m"
    exit 1
fi

# Check if user profile exists
if [ ! -f $config/user_profile.cfg ]
then
    echo -e "\e[31mError: printcfg user profile not found.\e[0m"
    exit 1
fi

# Acknowledge that the installation checks passed
echo -e "\e[32mprintcfg installation checks passed.\e[0m"
echo

# Success!
echo
echo -e "\e[32mPrintcfg has been successfully downloaded and installed.\e[0m"
echo

# Perform setup checks
echo "Performing Setup Checks..."
echo
source $home/$repo/scripts/setup.sh $src

# Check if setup.out exists
if [ -f setup.out ]
then
    cat setup.out
else
    echo -e "\e[32mSetup checks passed.\e[0m"
fi

echo

# Restart klipper
echo "Restarting klipper..."
systemctl restart klipper

# Restart moonraker
echo "Restarting moonraker..."
systemctl restart moonraker

echo
echo -e "\e[32mInstallation completed successfully.\e[0m"
