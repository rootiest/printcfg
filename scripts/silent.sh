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
##       Silent Loggger Script     ##
##      Version 4.0.0 2023-6-5     ##
#####################################

# This script will run other scripts silently and log the output to a file.

####################################################################################################

# Set the dev and repo name
REPO="printcfg"
# Get home directory
HOME=$(eval echo ~"$USER")
# Get full path to script
MY_SELF=$(readlink -f "$0")
# Get path to script
MY_PATH=$(dirname "$MY_SELF")

# import logger4bash
source "$HOME"/$REPO/src/log4bash.sh
# set default log file
LOGFILE="$HOME/$REPO/logs/silent.log"

# Verify a parameter was passed
if [ -z "$1" ]; then
    log_error "No parameter passed to silent logger script."
    exit 1
else
    # Set the parameter to a variable
    SCRIPT="$1"
    # Extract just the script name from the path
    SCRIPT_NAME=$(basename "$SCRIPT")
    # Remove the extension from the script name
    SCRIPT_NAME="${SCRIPT_NAME%.*}"
    # Set the log file name
    LOGFILE="$HOME/$REPO/logs/$SCRIPT_NAME.log"
    # Verify the script exists
    if [ ! -f "$SCRIPT" ]; then
        # Check if it is in a relative path
        if [ -f "$HOME/$REPO/$SCRIPT" ]; then
            SCRIPT="$HOME/$REPO/$SCRIPT"
            elif [ -f "$MY_PATH/$SCRIPT" ]; then
            SCRIPT="$MY_PATH/$SCRIPT"
        else
            log_error "Script $SCRIPT does not exist."
            exit 1
        fi
    fi
fi

log_info "Script $SCRIPT_NAME passed to silent logger script."
log_info "Output will be saved to $LOGFILE."

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$LOGFILE" 2>&1

# Find the extension of the script
EXTENSION="${SCRIPT##*.}"

# Verify the script is executable
if [ ! -x "$SCRIPT" ]; then
    log_error "Script $SCRIPT is not executable."
    # Check if it is a python script
    if [[ "$EXTENSION" == *.py ]]; then
        log_debug "Script $SCRIPT is a python script."
        # Check if python is installed
        if ! command -v python3 &>/dev/null; then
            log_error "Python3 is not installed."
            exit 1
        else
            log_debug "Python3 is installed."
            #Check if the script can be executed by python3
            if ! python3 "$SCRIPT"; then
                log_error "Script $SCRIPT is not executable."
                exit 1
            else
                log_debug "Script $SCRIPT is executable as a python script."
                # Add python3 to the script
                SCRIPT="python3 $SCRIPT"
            fi
        fi
        # Check if the scropt is a shell script
        elif [[ "$EXTENSION" == "sh" ]]; then
        log_debug "Script $SCRIPT is a shell script."
        # Check if the script is executable
        if ! bash "$SCRIPT"; then
            log_error "Script $SCRIPT is not executable."
            exit 1
        else
            log_debug "Script $SCRIPT is executable as a shell script."
            # Add bash to the script
            SCRIPT="bash $SCRIPT"
        fi
    else
        log_error "Script $SCRIPT is not executable."
        exit 1
    fi
fi

# log start of script
log_info "Starting $SCRIPT_NAME silently..."

# Run the script and log the output
$SCRIPT
