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
##      Version 4.0.0 2023-6-5     ##
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
# Define the klipper config paths
printer_data=$home/printer_data
config=$printer_data/config
# Define the printer.cfg and moonraker.conf files
printer=$config/printer.cfg
moonraker=$config/moonraker.conf
# Set the default profile
default_src=default

LOGFILE="$home/$repo/logs/install.log"
exec 3>&1 1>"$LOGFILE" 2>&1
trap "echo 'ERROR: An error occurred during execution, check log $LOGFILE for details.' >&3" ERR
trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG

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
echo "Welcome to the $repo install script." >&3
echo "This script will download and install the $repo package from GitHub." >&3

echo >&3
echo "Checking dependencies..." >&3
if ! which git > /dev/null; then
    need_git=true
    echo "Missing git." >&3
fi
if ! which pip > /dev/null; then
    need_pip=true
    echo "Missing pip." >&3
    sudo apt-get install python3-pip
fi
if ! which bc > /dev/null; then
    need_bc=true
    echo "Missing bc." >&3
    sudo apt-get install bc
fi
## Install missing dependencies
if [ -n "$need_git" ] || [ -n "$need_pip" ] || [ -n "$need_bc" ]; then
    echo "Installing missing dependencies..." >&3
    sudo apt update
    sudo apt-get install -y git python3-pip bc
else
    echo -e "\e[32mAll dependencies are installed.\e[0m" >&3
fi
echo "Installing $repo..." >&3

# Check if the repo exists
if ! git ls-remote https://github.com/"$dev"/"$repo" >/dev/null; then
    echo "The repo does not exist." >&3
    exit 1
fi

# Change to the home directory
cd $home

# Check if printcfg is already installed
if [ -d $home/$repo ];
then
    echo -e "\e[33m$repo repo is already installed.\e[0m" >&3
    echo "Updating $repo repo..." >&3
    # Change to the repo directory
    cd $home/$repo
    # Pull the latest changes
    git pull
else
    echo "Installing $repo repo..." >&3
    # Clone the repo
    git clone https://github.com/"$dev"/"$repo"
    # Check if the repo was cloned
    if [ ! -d $home/$repo ]; then
        echo -e "\e[31mError: Repo not cloned.\e[0m" >&3
        exit 1
    else
        echo "Repo cloned successfully." >&3
    fi
fi

# Change to the repo directory
cd $home/$repo

# Find the current branch
current_branch=$(git branch --show-current)

# Check if the branch was provided
if [ -n "$2" ]
then
    echo "Checking out branch $branch..." >&3
    # Check if the branch exists
    if ! git ls-remote --heads
    then
        echo -e "\e[31mError: Branch $branch does not exist.\e[0m" >&3
        exit 1
    fi
else
    echo "Staying on branch $current_branch..." >&3
    branch=$current_branch
fi

# Check if the branch is already checked out
if [ "$current_branch" != "$branch" ]; then
    git switch $branch
    # Check if the branch was switched
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError: Branch not switched.\e[0m" >&3
        exit 1
    else
        echo -e "\e[32mBranch switched successfully.\e[0m" >&3
        pull_branch=true
    fi
else
    echo -e "\e[33mAlready on branch $branch.\e[0m"
fi

# Pull the latest changes
if [ -n "$pull_branch" ]; then
    echo "Pulling latest changes..." >&3
    git pull
fi

### Run any setup scripts ###

# Install the dependencies
echo "Installing dependencies..." >&3
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt
    echo -e "\e[32mDependencies installed successfully.\e[0m" >&3
else
    echo -e "\e[33mNo dependencies to install.\e[0m" >&3
fi

# Check if the service is enabled
echo "Checking if the ${repo} service is enabled..." >&3
if systemctl is-enabled "${repo}" >/dev/null 2>&1; then
    echo "The ${repo} service is enabled." >&3
else
    echo "Installing the ${repo} service..." >&3
    echo "Acquiring root privileges..." >&3
    # Acquire root privileges
    sudo -v </dev/tty
    # Install the python package
    if [ -f $home/$repo/src/$repo.py ]; then
        python3 $home/$repo/src/$repo.py install
        echo -e "\e[32m${repo} service installed successfully.\e[0m" >&3
    fi
fi

# Create printcfg bin
if [ ! -f /usr/local/bin/$repo ]; then
    echo "Creating $repo bin..." >&3
    sudo ln -s $home/$repo/src/$repo.py /usr/local/bin/$repo
    sudo chmod +x /usr/local/bin/$repo
    echo -e "\e[32m$repo bin created successfully.\e[0m" >&3
fi

### Install into klippers config ###

# Check if config directory exists
if [ ! -d "$config" ]
then
    echo -e "\e[31mError: Directory '$config' not found.\e[0m" >&3
    echo "Please make sure you have klipper installed and your config is located in $config" >&3
    exit 1
fi

# Check if the file exists
if [ ! -f "$printer" ]
then
    echo -e "\e[31mError: File '$printer' not found.\e[0m" >&3
    echo "Please make sure you have klipper installed and your config is located in $printer" >&3
    exit 1
fi

# Check if user_config file exists
if [ ! -f $config/user_config.cfg ]
then
    # Check if profile config exists
    if [ ! -f $home/$repo/profiles/$src/config.cfg ]
    then
        echo -e "\e[31mError: Config Profile '$src' not found.\e[0m" >&3
        echo "Using default config profile: $default_src" >&3
        src=$default_src
    fi
    # Copy user profile to config directory
    echo -e "\e[36mUsing config profile: $src\e[0m" >&3
    echo "Creating user_config in config directory..." >&3
    cp -r $home/$repo/profiles/$src/config.cfg $config/user_config.cfg
else
    echo -e "\e[32mUser config already exists.\e[0m" >&3
fi

# Check if user profile file exists
if [ ! -f $config/user_profile.cfg ]
then
    # Check if profile exists
    if [ ! -f $home/$repo/profiles/$src/variables.cfg ]
    then
        echo -e "\e[31mError: Profile '$src' not found.\e[0m" >&3
        echo "Using default variables profile: $default_src" >&3
        src=$default_src
    fi
    # Copy user profile to config directory
    echo -e "\e[36mUsing variables profile: $src\e[0m" >&3
    echo "Creating user profile in config directory..." >&3
    cp -r $home/$repo/profiles/$src/variables.cfg $config/user_profile.cfg
else
    echo -e "\e[32mUser profile already exists.\e[0m" >&3
fi

# Check if link already exists
if [ ! -L $config/$repo ]
then
    # Link printcfg to the printer config directory
    echo "Linking $repo to the printer config directory..." >&3
    ln -s $home/$repo $config/$repo
    # Check if the link was created
    if [ ! -L $config/$repo ]
    then
        echo -e "\e[31mError: Link not created.\e[0m" >&3
        exit 1
    fi
else
    echo -e "\e[33m$repo symlink already exists.\e[0m" >&3
fi

# Check if include line exists in printer.cfg
uconfig_pattern="[include user_config.cfg]"
if grep -qFx "$uconfig_pattern" "$printer"
then
    echo -e "\e[33m$repo config already included.\e[0m" >&3
else
    echo "Adding $repo config to $printer..." >&3
    # Add printcfg config to beginning of file
    python3 $home/$repo/src/search_replace.py "$uconfig_pattern" "$uconfig_pattern" "$printer"
fi

# Verify moonraker is installed
if [ ! -f "$moonraker" ]
then
    echo -e "\e[31mError: File '$moonraker' not found.\e[0m" >&3
    echo "Please make sure you have moonraker installed and your config is located in $moonraker" >&3
    exit 1
fi

# Check if the moonraker-printcfg.conf file exists
if [ ! -f $config/moonraker-$repo.conf ]
then
    # Copy moonraker config to config directory
    echo "Creating moonraker config in config directory..." >&3
    cp -r $home/$repo/src/mooncfg.conf $config/moonraker-$repo.conf
else
    echo -e "\e[32mMoonraker config already exists.\e[0m" >&3
fi

# Set branch in moonraker-printcfg.conf
echo "Setting branch in moonraker config..." >&3
# Define search pattern
branch_pattern="primary_branch:"
# Set branch to current branch
python3 $home/$repo/src/search_replace.py "$branch_pattern" "$branch_pattern $branch" "$config/moonraker-$repo.conf"

# Check if the moonraker config already contains the old printcfg config
moon_pattern="[include $repo/moonraker-$repo.conf]"
new_moon="[include moonraker-$repo.conf]"

if grep -qFx "$new_moon" "$moonraker"
then
    echo -e "\e[33m$repo moonraker already included.\e[0m" >&3
else
    echo "Adding $repo config to $moonraker..." >&3
    # Add printcfg config to moonraker
    python3 $home/$repo/src/search_replace.py "$moon_pattern" "$new_moon" "$moonraker"
fi

# Add printcfg to moonraker.asvc
echo "Checking for $repo service in moonraker allowlist..." >&3
# Define allowlist file
allowlist="$printer_data/moonraker.asvc"
# Verify printcfg is in allowlist
if grep -qFx "$repo" "$allowlist"
then
    echo -e "\e[33m$repo service already in allowlist.\e[0m" >&3
else
    echo "Adding $repo service to moonraker allowlist..." >&3
    # Add printcfg service to moonraker allowlist
    echo "$repo" >> $allowlist
    if grep -qFx "$repo" "$allowlist"
    then
        echo -e "\e[32m$repo service added to allowlist successfully.\e[0m" >&3
    else
        echo -e "\e[31mError: $repo service not added to allowlist.\e[0m" >&3
        exit 1
    fi
fi

echo -e "\e[32mInstall complete.\e[0m" >&3
echo >&3

# Perform all checks to make sure printcfg is installed correctly
echo "Checking $repo installation..." >&3

# Check if the repo exists
if [ ! -d $home/$repo ]; then
    echo -e "\e[31mError: Repo not cloned.\e[0m" >&3
    exit 1
fi

# Check if the printer.cfg exists
if [ ! -f "$printer" ]
then
    echo -e "\e[31mError: File '$printer' not found.\e[0m" >&3
    echo "Please make sure you have klipper installed and your config is located in $printer" >&3
    exit 1
fi

# Check if moonraker config exists
if [ ! -f "$moonraker" ]
then
    echo -e "\e[31mError: File '$moonraker' not found.\e[0m" >&3
    echo "Please make sure you have moonraker installed and your config is located in $moonraker" >&3
    exit 1
fi

# Check if printcfg is included in the printer.cfg file
if ! grep -qFx "$uconfig_pattern" "$printer"
then
    echo -e "\e[31mError: $repo config not included in $printer\e[0m" >&3
    exit 1
fi

# Check if the moonraker config contains printcfg config
if ! grep -qFx "$new_moon" "$moonraker"
then
    echo -e "\e[31mError: $repo config not included in $moonraker\e[0m" >&3
    exit 1
fi

# Check if printcfg symlink exists
if [ ! -L $config/$repo ]
then
    echo -e "\e[31mError: $repo symlink not created.\e[0m" >&3
    exit 1
fi

# Check if user config exists
if [ ! -f $config/user_config.cfg ]
then
    echo -e "\e[31mError: $repo user config not found.\e[0m" >&3
    exit 1
fi

# Check if user profile exists
if [ ! -f $config/user_profile.cfg ]
then
    echo -e "\e[31mError: $repo user profile not found.\e[0m" >&3
    exit 1
fi

# Acknowledge that the installation checks passed
echo -e "\e[32m$repo installation checks passed.\e[0m" >&3
echo

# Success!
echo >&3
echo -e "\e[32mPrintcfg has been successfully downloaded and installed.\e[0m" >&3
echo >&3

# Perform setup checks
echo "Performing Setup Checks..." >&3
echo >&3

bash $home/$repo/scripts/setup.sh $src

echo -e "\e[32mSetup checks passed.\e[0m" >&3

echo >&3

# Restart klipper
echo "Restarting klipper..." >&3
systemctl restart klipper

# Restart moonraker
echo "Restarting moonraker..." >&3
systemctl restart moonraker

echo >&3
echo -e "\e[32mInstallation completed successfully.\e[0m" >&3
