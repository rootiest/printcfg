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

# Set the dev and repo name
dev="rootiest"
repo="printcfg"
branch="master"
# Get home directory
home=$(eval echo ~"$USER")
# Define the klipper config paths
printer_data=$home/printer_data
config=$printer_data/config
# Define the printer.cfg and moonraker.conf files
printer=$config/printer.cfg
moonraker=$config/moonraker.conf
# Set the default profile
default_src=default
# Set the config file
REPO_DATA="$home"/$repo/$repo.conf

# import logger4bash
# shellcheck source=/dev/null
source "$home"/$repo/src/log4bash.sh
# set log file
LOGFILE="$home/$repo/logs/install.log"

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$LOGFILE" 2>&1

# log start of script
log_info "Starting $repo install script..."


#trap "echo 'ERROR: An error occurred during execution, check log for details.' >&3" ERR
#trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG

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

# Determine profile
function determine_profile() {
    # Set user vars
    user_vars="$config"/user_profile.cfg
    # Log user vars
    log_debug "user_vars=$user_vars"
    # Read profile from user_pofile.cfg
    if [ -f "$user_vars" ]
    then
        profile_pattern="# Profile:"
        # Find profile in user_pofile.cfg (the rest of the line after the pattern)
        profile=$(grep "$profile_pattern" "$user_vars" | sed "s/$profile_pattern//")
        # Log profile
        log_info "Profile set to $profile."
        echo "Profile set to $profile."
    else
        # Log lack of profile
        log_error "No profile set."
        echo "No profile set."
    fi
}

function read_repo_data() {
    # Check if REPO_DATA file exists
    log_info "Checking if $REPO_DATA exists..."
    if [ -f "$REPO_DATA" ]; then
        log_info "$REPO_DATA exists."
        # Read REPO_DATA file
        echo "Reading $REPO_DATA..."
        log_info "Reading $REPO_DATA..."
        # Read REPO_DATA file
        while IFS='=' read -r key value
        do
            # Set the key and value
            declare "$key=$value"
            # Log repo data
            log_debug "$key=$value"
        done < "$REPO_DATA"
        # Log repo data
        log_info "$REPO_DATA read."
    else
        log_info "$REPO_DATA does not exist. Falling back to defaults."
    fi
}

function store_repo_data() {
    # Set names
    determine_profile
    repo_dir=$home/$repo
    # Check if REPO_DATA file exists
    if [ ! -f "$REPO_DATA" ]
    then
        log_info "$REPO_DATA does not exist."
        echo "Creating $REPO_DATA..."
        # Create REPO_DATA file
        log_info "Creating $REPO_DATA..."
        touch "$REPO_DATA"
    else
        # Update REPO_DATA file
        echo "Updating $REPO_DATA..."
        # Delete REPO_DATA file
        rm "$REPO_DATA"
        # Create REPO_DATA file
        touch "$REPO_DATA"
    fi
    echo "Storing printcfg configuration in $REPO_DATA..."
    stty_orig=$(stty -g)
    stty -echo
    # Open printcfg config file for writing
    {
        # Add moonraker=$moonraker
        echo "moonraker=$moonraker"
        # Add printer=$printer
        echo "printer=$printer"
        # Add klipper=$klipper_service
        echo "klipper_service=$klipper_service"
        # Add klipper_dir=$klipper_dir
        echo "klipper_dir=$klipper_dir"
        # Add printer_dir=$printer_dir
        echo "printer_dir=$printer_dir"
        # Add moonraker_service=$moonraker_service
        echo "moonraker_service=$moonraker_service"
        # Add moonraker_dir=$moonraker_dir
        echo "moonraker_dir=$moonraker_dir"
        # Add allowlist=$allowlist
        echo "allowlist=$allowlist"
        # Add config=$config
        echo "config=$config"
        # Add repo=$repo
        echo "repo=$repo"
        # Add repo_dir=$repo_dir
        echo "repo_dir=$repo_dir"
        # Add profile=$profile
        echo "profile=$profile"
    } >> "$REPO_DATA"
    stty "$stty_orig"
    echo "printcfg configuration stored in $REPO_DATA."
}

# Check if a file exists
function file_exists() {
    if [ ! -f "$1" ]
    then
        echo -e "\e[31mError: Directory '$1' not found.\e[0m"
        echo "Please make sure you have $2 installed and your config is located in $1"
        exit 1
    fi
}

# Check if a directory exists
function dir_exists() {
    if [ ! -d "$1" ]
    then
        echo -e "\e[31mError: Directory '$1' not found.\e[0m"
        echo "Please make sure you have $2 installed and your config is located in $1"
        exit 1
    fi
}

# Check if profile exists
function profile_exists() {
    if [ ! -d "$home/$repo/profiles/$1" ]
    then
        echo -e "\e[31mError: Profile '$1' not found.\e[0m"
        echo "Please make sure you have $1 installed and your config is located in $home/$repo/$1"
    fi
}

# Welcome message
echo "Welcome to the $repo install script."
echo "This script will download and install the $repo package from GitHub."

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
if ! which wget > /dev/null; then
    need_wget=true
    echo "Missing wget."
    sudo apt-get install wget
fi

## Install missing dependencies
if [ -n "$need_git" ] || [ -n "$need_pip" ] || [ -n "$need_bc" ] || [ -n "$need_wget" ]; then
    echo "Installing missing dependencies..."
    sudo apt update
    sudo apt-get install -y git python3-pip bc wget
else
    echo -e "\e[32mAll dependencies are installed.\e[0m"
fi

echo "Installing $repo..."

# Check if the repo exists
if ! git ls-remote https://github.com/"$dev"/"$repo" >/dev/null; then
    echo "The repo does not exist."
    exit 1
fi

# Change to the home directory
cd "$home" || exit

# Check if printcfg is already installed
if [ -d "$home"/$repo ];
then
    echo -e "\e[33m$repo repo is already installed.\e[0m"
    echo "Updating $repo repo..."
    # Change to the repo directory
    cd "$home"/$repo || exit
    # Pull the latest changes
    git pull
else
    echo "Installing $repo repo..."
    # Clone the repo
    git clone https://github.com/"$dev"/"$repo"
    # Check if the repo was cloned
    if [ ! -d "$home"/$repo ]; then
        echo -e "\e[31mError: Repo not cloned.\e[0m"
        exit 1
    else
        echo "Repo cloned successfully."
    fi
fi

# Change to the repo directory
cd "$home"/$repo || exit

# Attempt to read REPO_DATA file
read_repo_data

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
    if ! git switch "$branch"; then
        echo -e "\e[31mError: Branch $branch does not exist.\e[0m"
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
echo "Installing dependencies..."
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt
    echo -e "\e[32mDependencies installed successfully.\e[0m"
else
    echo -e "\e[33mNo dependencies to install.\e[0m"
fi

# Check if the service is enabled
echo "Checking if the ${repo} service is enabled..."
if systemctl is-enabled "${repo}" >/dev/null 2>&1; then
    echo "The ${repo} service is enabled."
else
    echo "Installing the ${repo} service..."
    echo "Acquiring root privileges..."
    # Acquire root privileges
    sudo -v
    # Install the python package
    if [ -f "$home"/$repo/src/$repo.py ]; then
        python3 "$home"/$repo/src/$repo.py install
        echo -e "\e[32m${repo} service installed successfully.\e[0m"
    fi
fi

# Create printcfg bin
if [ ! -f /usr/local/bin/$repo ]; then
    echo "Creating $repo bin..."
    sudo ln -s "$home"/$repo/src/$repo.py /usr/local/bin/$repo
    sudo chmod +x /usr/local/bin/$repo
    echo -e "\e[32m$repo bin created successfully.\e[0m"
fi

# Look for and install log4bash if it is missing
if [ ! -f log4bash.sh ]; then
    # Look for log4bash in src directory
    if [ ! -f "$home"/$repo/src/log4bash.sh ]; then
        # Look for log4bash in home directory
        if [ ! -f "$home"/log4bash.sh ]; then
            # Look for log4bash in PATH
            if ! which log4bash.sh > /dev/null; then
                echo "Installing log4bash."
                # Download log4bash library
                wget https://raw.githubusercontent.com/fredpalmer/log4bash/master/log4bash.sh -O "$home"/$repo/src/log4bash.sh
                # Check if log4bash was downloaded
                if [ ! -f "$home"/$repo/src/log4bash.sh ]; then
                    echo -e "\e[31mError: log4bash not downloaded.\e[0m"
                    exit 1
                else
                    echo -e "\e[32mlog4bash downloaded successfully.\e[0m"
                    # symlink log4bash to usr/local/bin
                    echo "Creating log4bash bin..."
                    sudo ln -s "$home"/$repo/src/log4bash.sh /usr/local/bin/log4bash.sh
                    # Check if log4bash was symlinked
                    if [ ! -f /usr/local/bin/log4bash.sh ]; then
                        echo -e "\e[31mError: log4bash bin not created.\e[0m"
                        exit 1
                    else
                        # Check if log4bash was added to PATH
                        if ! which log4bash.sh > /dev/null; then
                            echo -e "\e[31mError: log4bash not added to PATH.\e[0m"
                            exit 1
                        else
                            # Check if log4bash is executable
                            if [ ! -x /usr/local/bin/log4bash.sh ]; then
                                # Make log4bash executable
                                sudo chmod +x /usr/local/bin/log4bash.sh
                                # Check if log4bash is executable
                                if [ ! -x /usr/local/bin/log4bash.sh ]; then
                                    echo -e "\e[31mError: log4bash not executable.\e[0m"
                                    exit 1
                                else
                                    echo -e "\e[32mlog4bash bin created successfully.\e[0m"
                                fi
                            else
                                echo -e "\e[32mlog4bash bin created successfully.\e[0m"
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi
fi

### Install into klippers config ###

# Check if config directory exists
dir_exists "$config" "klipper"

# Check if the file exists
file_exists "$printer" "klipper"

# Check if user_config file exists
if [ ! -f "$config"/user_config.cfg ]
then
    # Check if profile config exists
    if [ ! -f "$home"/$repo/profiles/"$src"/config.cfg ]
    then
        echo -e "\e[31mError: Config Profile '$src' not found.\e[0m"
        echo "Using default config profile: $default_src"
        src=$default_src
    fi
    # Copy user profile to config directory
    echo -e "\e[36mUsing config profile: $src\e[0m"
    echo "Creating user_config in config directory..."
    cp -r "$home"/$repo/profiles/"$src"/config.cfg "$config"/user_config.cfg
else
    echo -e "\e[32mUser config already exists.\e[0m"
fi

# Check if profile exists
profile_exists "$src"

# Check if user profile file exists
if [ ! -f "$config"/user_profile.cfg ]
then
    # Check if profile exists
    if [ ! -f "$home"/$repo/profiles/"$src"/variables.cfg ]
    then
        echo -e "\e[31mError: Profile '$src' not found.\e[0m"
        echo "Using default variables profile: $default_src"
        src=$default_src
    fi
    # Copy user profile to config directory
    echo -e "\e[36mUsing variables profile: $src\e[0m"
    echo "Creating user profile in config directory..."
    cp -r "$home"/$repo/profiles/"$src"/variables.cfg "$config"/user_profile.cfg
else
    echo -e "\e[32mUser profile already exists.\e[0m"
fi

# Check if link already exists
if [ ! -L "$config"/$repo ]
then
    # Link printcfg to the printer config directory
    echo "Linking $repo to the printer config directory..."
    ln -s "$home"/$repo "$config"/$repo
    # Check if the link was created
    if [ ! -L "$config"/$repo ]
    then
        echo -e "\e[31mError: Link not created.\e[0m"
        exit 1
    fi
else
    echo -e "\e[33m$repo symlink already exists.\e[0m"
fi

# Check if include line exists in printer.cfg
uconfig_pattern="[include user_config.cfg]"
if grep -qFx "$uconfig_pattern" "$printer"
then
    echo -e "\e[33m$repo config already included.\e[0m"
else
    echo "Adding $repo config to $printer..."
    # Add printcfg config to beginning of file
    python3 "$home"/$repo/src/search_replace.py "$uconfig_pattern" "$uconfig_pattern" "$printer"
fi

# Verify moonraker is installed
if [ -f /etc/systemd/system/moonraker.service ]
then
    moonraker_service=/etc/systemd/system/moonraker.service
    ## Look inside for the line starting with EnvironmentFile= and store the rest of that line
    moonraker_env=$(grep -oP '(?<=EnvironmentFile=).*' "$moonraker_service")
    ## Look inside for the line starting with WorkingDirectory= and store the rest of that line
    moonraker_dir=$(grep -oP '(?<=WorkingDirectory=).*' "$moonraker_service")
    if [ -f "$moonraker_env" ]
    then
        ## In that moonraker env file look for the part of the line that starts with -d and store the rest of that line
        printer_dir=$(grep -oP '(?<=-d ).*' "$moonraker_env")
        # Remove double-quote from the end of printer_dir
        printer_dir=${printer_dir%\"}
        ## Check if that printer_dir exists
        if [ ! -d "$printer_dir" ]
        then
            echo -e "\e[31mError: Directory '$printer_dir' not found.\e[0m"
            echo "Please make sure you have moonraker installed and your printer_data is located in $printer_dir"
            exit 1
        fi
    fi
fi
if [ ! -f "$moonraker" ]
then
    # Attempt to find moonraker service in /etc/systemd/system
    if [ ! -f /etc/systemd/system/moonraker.service ]
    then
        echo -e "\e[31mError: File '$moonraker' not found.\e[0m"
        echo "Please make sure you have moonraker installed and your config is located in $moonraker"
        exit 1
    else
        moonraker_service=/etc/systemd/system/moonraker.service
        ## Look inside for the line starting with EnvironmentFile= and store the rest of that line
        moonraker_env=$(grep -oP '(?<=EnvironmentFile=).*' "$moonraker_service")
        ## Look inside for the line starting with WorkingDirectory= and store the rest of that line
        moonraker_dir=$(grep -oP '(?<=WorkingDirectory=).*' "$moonraker_service")
        ## Check if that moonraker_env file exists
        if [ ! -f "$moonraker_env" ]
        then
            echo -e "\e[31mError: File '$moonraker_env' not found.\e[0m"
            echo "Please make sure you have moonraker installed and your config is located in $moonraker_env"
            exit 1
        else
            ## In that moonraker env file look for the part of the line that starts with -d and store the rest of that line
            printer_dir=$(grep -oP '(?<=-d ).*' "$moonraker_env")
            # Remove double-quote from the end of printer_dir
            printer_dir=${printer_dir%\"}
            ## Check if that printer_dir exists
            if [ ! -d "$printer_dir" ]
            then
                echo -e "\e[31mError: Directory '$printer_dir' not found.\e[0m"
                echo "Please make sure you have moonraker installed and your printer_data is located in $printer_dir"
                exit 1
            else
                ## Check if the file exists
                if [ ! -f "$printer_dir/config/moonraker.conf" ]
                then
                    echo -e "\e[31mError: File '$printer_dir/config/moonraker.conf' not found.\e[0m"
                    echo "Please make sure you have moonraker installed and your printer_data is located in $printer_dir/config/moonraker.conf"
                    exit 1
                else
                    moonraker="$printer_dir/config/moonraker.conf"
                fi
            fi
        fi
    fi
fi

## Repeat the same process for the klipper service
if [ -f /etc/systemd/system/klipper.service ]
then
    klipper_service=/etc/systemd/system/klipper.service
    klipper_env=$(grep -oP '(?<=EnvironmentFile=).*' "$klipper_service")
    klipper_dir=$(grep -oP '(?<=WorkingDirectory=).*' "$klipper_service")
fi
if [ ! -f "$printer" ]
then
    # if $klipper_service is not defined
    if [ -z "$klipper_service" ]
    then
        # Attempt to find klipper service in /etc/systemd/system
        klipper_service=/etc/systemd/system/klipper.service
    fi
    if [ ! -f "$klipper_service" ]
    then
        echo -e "\e[31mError: File '$klipper_service' not found.\e[0m"
        echo "Please make sure you have klipper installed and your config is located in $klipper_service"
        exit 1
    else
        klipper_service=/etc/systemd/system/klipper.service
        klipper_env=$(grep -oP '(?<=EnvironmentFile=).*' "$klipper_service")
        klipper_dir=$(grep -oP '(?<=WorkingDirectory=).*' "$klipper_service")
        if [ ! -f "$klipper_env" ]
        then
            echo -e "\e[31mError: File '$klipper_env' not found.\e[0m"
            echo "Please make sure you have klipper installed and your config is located in $klipper_env"
            exit 1
        else
            printer_dir=$(grep -oP '(?<=-d ).*' "$klipper_env")
            if [ ! -d "$printer_dir" ]
            then
                echo -e "\e[31mError: Directory '$printer_dir' not found.\e[0m"
                echo "Please make sure you have klipper installed and your config is located in $printer_dir"
                exit 1
            else
                if [ ! -f "$printer_dir"/config/printer.cfg ]
                then
                    echo -e "\e[31mError: File '$printer_dir'/printer.cfg not found.\e[0m"
                    echo "Please make sure you have klipper installed and your config is located in $printer_dir/config/printer.cfg"
                    exit 1
                else
                    printer_data=$printer_dir
                    config="$printer_dir/config"
                    klipper_service=/etc/systemd/system/klipper.service
                    klipper_env=$(grep -oP '(?<=EnvironmentFile=).*' "$klipper_service")
                    klipper_dir=$(grep -oP '(?<=WorkingDirectory=).*' "$klipper_service")
                fi
            fi
        fi
    fi
fi

# Check if the moonraker-printcfg.conf file exists
if [ ! -f "$config"/moonraker-$repo.conf ]
then
    # Copy moonraker config to config directory
    echo "Creating moonraker config in config directory..."
    cp -r "$home"/$repo/src/mooncfg.conf "$config"/moonraker-$repo.conf
else
    echo -e "\e[32mMoonraker config already exists.\e[0m"
fi

# Set branch in moonraker-printcfg.conf
echo "Setting branch in moonraker config..."
# Define search pattern
branch_pattern="primary_branch:"
# Set branch to current branch using sed
sed -i "s/$branch_pattern.*/$branch_pattern $branch/" "$config"/moonraker-$repo.conf
#python3 "$home"/$repo/src/search_replace.py "$branch_pattern" "$branch_pattern $branch" "$config/moonraker-$repo.conf"

# Check if the moonraker config already contains the old printcfg config
moon_pattern="[include $repo/moonraker-$repo.conf]"
new_moon="[include moonraker-$repo.conf]"

if grep -qFx "$new_moon" "$moonraker"
then
    echo -e "\e[33m$repo moonraker already included.\e[0m"
else
    echo "Adding $repo config to $moonraker..."
    # Add printcfg config to moonraker
    python3 "$home"/$repo/src/search_replace.py "$moon_pattern" "$new_moon" "$moonraker"
fi

# Add printcfg to moonraker.asvc
echo "Checking for $repo service in moonraker allowlist..."
# Define allowlist file
allowlist="$printer_data/moonraker.asvc"
# Verify printcfg is in allowlist
if grep -qFx "$repo" "$allowlist"
then
    echo -e "\e[33m$repo service already in allowlist.\e[0m"
else
    echo "Adding $repo service to moonraker allowlist..."
    # Add printcfg service to moonraker allowlist
    echo "$repo" >> "$allowlist"
    if grep -qFx "$repo" "$allowlist"
    then
        echo -e "\e[32m$repo service added to allowlist successfully.\e[0m"
    else
        echo -e "\e[31mError: $repo service not added to allowlist.\e[0m"
        exit 1
    fi
fi

echo -e "\e[32mInstall complete.\e[0m"
echo

# Store repo data
store_repo_data

# Perform all checks to make sure printcfg is installed correctly
echo "Checking $repo installation..."

# Check if the repo exists
if [ ! -d "$home"/$repo ]; then
    echo -e "\e[31mError: Repo not cloned.\e[0m"
    exit 1
fi

# Check if the printer.cfg exists
file_exists "$printer" "klipper"

# Check if moonraker config exists
file_exists "$moonraker" "moonraker"

# Verify the moonraker allowlist exists
file_exists "$allowlist" "moonraker allowlist"

# Check if printcfg is included in the printer.cfg file
if ! grep -qFx "$uconfig_pattern" "$printer"
then
    echo -e "\e[31mError: $repo config not included in $printer\e[0m"
    exit 1
fi

# Check if the moonraker config contains printcfg config
if ! grep -qFx "$new_moon" "$moonraker"
then
    echo -e "\e[31mError: $repo config not included in $moonraker\e[0m"
    exit 1
fi

# Check if printcfg symlink exists
if [ ! -L "$config"/$repo ]
then
    echo -e "\e[31mError: $repo symlink not created.\e[0m"
    exit 1
fi

# Check if user config exists
if [ ! -f "$config"/user_config.cfg ]
then
    echo -e "\e[31mError: $repo user config not found.\e[0m"
    exit 1
fi

# Check if user profile exists
if [ ! -f "$config"/user_profile.cfg ]
then
    echo -e "\e[31mError: $repo user profile not found.\e[0m"
    exit 1
fi

# Acknowledge that the installation checks passed
echo -e "\e[32m$repo installation checks passed.\e[0m"
echo

# Success!
echo
echo -e "\e[32mPrintcfg has been successfully downloaded and installed.\e[0m"
echo

# Perform setup checks
echo "Performing Setup Checks..."
echo

bash "$home"/$repo/scripts/setup.sh "$src"

echo -e "\e[32mSetup checks passed.\e[0m"

echo

# Store repo data
store_repo_data

# Restart klipper
echo "Restarting klipper..."
systemctl restart klipper

# Restart moonraker
echo "Restarting moonraker..."
systemctl restart moonraker

echo
echo -e "\e[32mInstallation completed successfully.\e[0m"
