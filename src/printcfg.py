#!/usr/bin/env python3
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

# This is the printcfg process that runs in the background.
# It also manages the printcfg service.
# Usage: python3 printcfg.py [mode]
# Modes:
#   default: Run the script normally (default)
#   install: Install the printcfg service
#   change: Change the printcfg profile
#   remove: Remove the printcfg service
#   update: Update printcfg

#!/usr/bin/env python3

import os
import sys
import getpass
import subprocess
import logging
import datetime

logger: logging.Logger = logging.getLogger(__name__)

# Set the repo name
REPO = "printcfg"

# Get the current user name
current_user = getpass.getuser()
user_home = os.path.expanduser("~")
profile_path = f"{user_home}/printer_data/config/user_profile.cfg"
setup_script = f"{user_home}/printcfg/scripts/setup.sh"

# Set the logfile
logfile = f"{user_home}/printcfg/logs/printcfg.log"

# Check the date of the first log entry
# If it is older than 30 days, delete the logfile
if os.path.exists(logfile):
    with open(logfile, "r", encoding="utf-8") as file:
        first_line = file.readline()
        if first_line:
            first_line = first_line.split(" - ")[0]
            first_line = datetime.datetime.strptime(first_line, "%Y-%m-%d %H:%M:%S,%f")
            thirty_days_ago = datetime.datetime.now() - datetime.timedelta(days=30)
            if first_line < thirty_days_ago:
                os.remove(logfile)

# Check if the logfile exists
if not os.path.exists(f"{user_home}/printcfg/logs/"):
    # Create the log directory
    os.mkdir(f"{user_home}/printcfg/logs/")
    # Create the logfile
    with open(logfile, "w", encoding="utf-8") as file:
        pass

# Set the logging level
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler = logging.FileHandler(logfile)
handler.setFormatter(formatter)
logger.addHandler(handler)

def find_profile(path):
    logger.debug("Searching for profile name in file: {}".format(path))
    # Find the profile name (Eg: '# Profile: default' = 'default')
    with open(path, "r", encoding="utf-8") as file:
        for line in file:
            if line.startswith("# Profile: "):
                logger.debug("Found profile name: {}".format(line[11:].strip()))
                # Return the profile name
                return line[11:].strip()

    # If no profile was found, raise an error
    logger.error("Profile not found in file: {}".format(path))
    raise ValueError("Profile not found in file: {}".format(path))

def normal_ops():
    logger.info("Starting normal operations...")
    try:
        # Run the shell script at startup
        subprocess.Popen(["/bin/bash", setup_script])
        logger.info("Startup script complete.")
    except Exception as e:
        # Log the error
        logger.error("Error running startup script: {}".format(str(e)))
        # Exit with error
        exit(1)
    # Exit successfully
    logger.info("Startup script complete, exiting.")
    exit(0)

def generate_service():
    logger.info("Generating service...")
    # Define the path to the second script
    script_dir = f"{user_home}/{REPO}/"
    logger.debug("Script directory: {}".format(script_dir))
    mode = sys.argv[1]
    logger.debug("Mode: {}".format(mode))
    # Define the path to the second script
    script_path = f"{script_dir}/src/gen_service.py"
    logger.debug("Script path: {}".format(script_path))
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        logger.error("Error: The script '{}' does not exist.".format(script_path))
        return
    # Start the second script as root with the current user name as the first argument
    command = ["sudo", "python3", script_path, current_user, user_home, mode]
    logger.debug("Executing command: {}".format(command))
    print(f"Executing command: {command}")
    try:
        result = subprocess.run(command, capture_output=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: The subprocess returned an error.")
        print(e.stderr)
        logger.error("Error: The subprocess returned an error: {}".format(e.stderr))
        return
    logger.debug("Command output: {}".format(result.stdout.decode("utf-8")))
    if result.returncode != 0:
        print(f"Error: The command '{command}' failed with code {result.returncode}.")
        logger.error("Error: The command '{}' failed with code {}.".format(command, result.returncode))
        print(f"Output from command: {result.stdout.decode('utf-8')}")
        print(f"Error from command: {result.stderr.decode('utf-8')}")
        return
    # Exit successfully
    logger.info("Service generated successfully.")
    exit(0)

def change_profile(profile):
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/change_profile.sh"
    logger.debug("Script path: {}".format(script_path))
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        logger.error("Error: The script '{}' does not exist.".format(script_path))
        return
    # Start the change profile script
    command = ["bash", script_path, profile]
    logger.debug("Executing command: {}".format(command))
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print("Error: The subprocess returned an error.")
        print(e.stderr)
        logger.error("Error: The subprocess returned an error: {}".format(e.stderr))
    # Exit successfully
    logger.info("Profile changed successfully.")
    exit(0)

def update_printcfg():
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/install.sh"
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Find the current profile
    profile = find_profile(profile_path)
    # Start the update script
    command = ["bash", script_path, profile]
    logger.debug("Executing command: {}".format(command))
    try:
        subprocess.run(command)
    except subprocess.CalledProcessError as e:
        print("Error: The subprocess returned an error.")
        print(e.stderr)
        logger.error("Error: The subprocess returned an error: {}".format(e.stderr))
    # Exit successfully
    logger.info("Update complete.")
    exit(0)

def remove_printcfg():
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/remove_{REPO}.sh"
    logger.debug("Script path: {}".format(script_path))
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        logger.error("Error: The script '{}' does not exist.".format(script_path))
        return
    # Start the second script as root with the current user name as the first argument
    command = ["bash", script_path]
    logger.debug("Executing command: {}".format(command))
    try:
        subprocess.run(command)
    except subprocess.CalledProcessError as e:
        print("Error: The subprocess returned an error.")
        print(e.stderr)
        logger.error("Error: The subprocess returned an error: {}".format(e.stderr))
    # Exit successfully
    logger.info("Printcfg removed successfully.")
    exit(0)

def show_help():
    print(f"Usage: {sys.argv[0]} [install|change|remove|update|help]")
    print(f"  install: Install {REPO} service")
    print(f"  change: Change the current profile")
    print(f"  remove: Remove {REPO} service")
    print(f"  update: Update {REPO}")
    print(f"  help: Show this help message")
    exit(0)

if __name__ == "__main__":
    # Check if there are any arguments
    if len(sys.argv) < 2:
        logger.info("No arguments provided, running normal operations.")
        normal_ops()
        sys.exit(1)
    # Check the argument
    if sys.argv[1] not in ["install", "change", "remove", "update", "help"]:
        print(
            "Error: The argument must be either install, change, remove, update, or help."
        )
        logger.error("Error: The argument must be either install, change, remove, update, or help.")
        sys.exit(1)
    # If the argument is 'install' start the script as root
    if sys.argv[1] == "install":
        logger.info("Running install operations.")
        generate_service()
    # If the argument is 'change' check for a second argument
    elif sys.argv[1] == "change":
        if len(sys.argv) != 3:
            print("Error: The change script requires two arguments.")
            print(f"Usage: python3 {REPO}.py change <profile>")
            logger.error("Error: The change script requires two arguments.")
            sys.exit(1)
        else:
            # Check if the profile exists
            profile = sys.argv[2]
            logger.info("Running change operations.")
            profile_path = f"{user_home}/{REPO}/profiles/{profile}"
            logger.debug("Profile path: {}".format(profile_path))
            print(f"Changing to profile '{profile}'")
            # If the profile is 'backup' then skip the check
            if profile == "backup":
                logger.info("Changing to backup profile.")
                change_profile(profile)
            else:
                # If the profile path does not exist, exit
                if not os.path.isdir(profile_path):
                    print(f"Error: The profile '{profile}' does not exist.")
                    logger.error("Error: The profile '{}' does not exist.".format(profile))
                    sys.exit(1)
                else:
                    logger.info("Changing to profile '{}'.".format(profile))
                    change_profile(profile)
    # If the argument is 'remove'
    elif sys.argv[1] == "remove":
        logger.info("Running remove operations.")
        remove_printcfg()
    elif sys.argv[1] == "update":
        logger.info("Running update operations.")
        update_printcfg()
    elif sys.argv[1] == "help":
        logger.info("Running help operations.")
        show_help()
    else:
        logger.info("Running normal operations.")
        normal_ops()
