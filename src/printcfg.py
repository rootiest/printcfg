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
    '''Find the profile name in the given file.'''
    logger.debug("Searching for profile name in file: %s",path)
    # Find the profile name (Eg: '# Profile: default' = 'default')
    with open(path, "r", encoding="utf-8") as p_file:
        for line in p_file:
            if line.startswith("# Profile:"):
                the_profile = line[10:].strip()
                logger.debug("Found profile name: %s", the_profile)
                # Return the profile name
                return the_profile

    # If no profile was found, raise an error
    logger.error("Profile not found in file: %s", path)
    raise ValueError(f"Profile not found in file: {path}")

def normal_ops():
    '''Run the script normally.'''
    logger.info("Starting normal operations...")
    try:
        # Run the shell script at startup
        subprocess.Popen(["/bin/bash", setup_script])
        logger.info("Startup script complete.")
    except subprocess.CalledProcessError as err:
        # Log the error
        logger.error("Error running startup script: %s", str(err))
        # Exit with error
        sys.exit(1)
    # Exit successfully
    logger.info("Startup script complete, exiting.")
    sys.exit(0)

def generate_service():
    '''Generate the printcfg service.'''
    logger.info("Generating service...")
    # Define the path to the second script
    script_dir = f"{user_home}/{REPO}/"
    logger.debug("Script directory: %s", script_dir)
    mode = sys.argv[1]
    logger.debug("Mode: %s", mode)
    # Define the path to the second script
    script_path = f"{script_dir}src/gen_service.py"
    logger.debug("Script path: %s", script_path)
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        logger.error("Error: The script '%s' does not exist.", script_path)
        return
    # Start the second script as root with the current user name as the first argument
    command = f"sudo python3 {script_path} {current_user} {user_home} {mode}"
    logger.debug("Executing command: %s", command)
    print(f"Executing command: {command}")
    try:
        result = subprocess.run(command, capture_output=True, check=False)
    except subprocess.CalledProcessError as err:
        print("Error: The subprocess returned an error.")
        print(err.stderr)
        logger.error("Error: The subprocess returned an error: %s", err.stderr)
        return
    logger.debug("Command output: %s", result.stdout.decode("utf-8"))
    if result.returncode != 0:
        print(f"Error: The command '{command}' failed with code {result.returncode}.")
        logger.error("Error: The command '%s' failed with code %s.", command, result.returncode)
        print(f"Output from command: {result.stdout.decode('utf-8')}")
        print(f"Error from command: {result.stderr.decode('utf-8')}")
        return
    # Exit successfully
    logger.info("Service generated successfully.")
    sys.exit(0)

def change_profile(profile_name: str):
    '''Change the profile.'''
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/change_profile.sh"
    logger.debug("Script path: %s", script_path)
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        logger.error("Error: The script '%s' does not exist.", script_path)
        return
    # Start the change profile script
    command = ["bash", script_path, profile_name]
    logger.debug("Executing command: %s", command)
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as err:
        print("Error: The subprocess returned an error.")
        print(err.stderr)
        logger.error("Error: The subprocess returned an error: %s", err.stderr)
    # Exit successfully
    logger.info("Profile changed successfully.")
    sys.exit(0)

def update_printcfg():
    '''Update printcfg.'''
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/install.sh"
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Find the current profile
    profile_name = find_profile(profile_path)
    # Start the update script
    command = ["bash", script_path, profile_name]
    logger.debug("Executing command: %s", command)
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as err:
        print("Error: The subprocess returned an error.")
        print(err.stderr)
        logger.error("Error: The subprocess returned an error: %s", err.stderr)
    # Exit successfully
    logger.info("Update complete.")
    sys.exit(0)

def remove_printcfg():
    '''Remove printcfg.'''
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/remove_{REPO}.sh"
    logger.debug("Script path: %s", script_path)
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        logger.error("Error: The script '%s' does not exist.", script_path)
        return
    # Start the second script as root with the current user name as the first argument
    command = ["bash", script_path]
    logger.debug("Executing command: %s", command)
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as err:
        print("Error: The subprocess returned an error.")
        print(err.stderr)
        logger.error("Error: The subprocess returned an error: %s", err.stderr)
    # Exit successfully
    logger.info("Printcfg removed successfully.")
    sys.exit(0)

def show_status():
    '''Show the status of the service.'''
    # Get the systemctl status
    command = ["systemctl", "status", f"{REPO}.service"]
    logger.debug("Executing command: %s", command)
    try:
        result = subprocess.run(command, capture_output=True, check=False)
    except subprocess.CalledProcessError as err:
        print("Error: The subprocess returned an error.")
        print(err.stderr)
        logger.error("Error: The subprocess returned an error: %s", err.stderr)
        return
    logger.debug("Command output: %s", result.stdout.decode("utf-8"))
    if result.returncode != 0:
        print(f"Error: The command '{command}' failed with code {result.returncode}.")
        logger.error("Error: The command '%s' failed with code %s.", command, result.returncode)
        print(f"Output from command: {result.stdout.decode('utf-8')}")
        print(f"Error from command: {result.stderr.decode('utf-8')}")
        return
    # Print the status
    print(result.stdout.decode("utf-8"))
    # Exit successfully
    logger.info("Status shown successfully.")
    sys.exit(0)

def show_help():
    '''Show the help message.'''
    print(f"Usage: {sys.argv[0]} [install|change|remove|update|help]")
    print(f"  install: Install {REPO} service")
    print("  change: Change the current profile")
    print(f"  remove: Remove {REPO} service")
    print(f"  update: Update {REPO}")
    print("  status: Show the status of the service")
    print("  help: Show this help message")
    sys.exit(0)

if __name__ == "__main__":
    # Check if there are any arguments
    if len(sys.argv) < 2:
        logger.info("No arguments provided, running normal operations.")
        normal_ops()
        sys.exit(1)
    # Check the argument
    if sys.argv[1] not in ["install", "change", "remove", "update", "status", "help"]:
        print(f"Error: Invalid Argument: {sys.argv[1]}")
        logger.error("Error: Invalid Argument: %s", sys.argv[1])
        show_help()
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
            logger.debug("Profile path: %s", profile_path)
            print(f"Changing to profile '{profile}'")
            # If the profile is 'backup' then skip the check
            if profile == "backup":
                logger.info("Changing to backup profile.")
                change_profile(profile)
            else:
                # If the profile path does not exist, exit
                if not os.path.isdir(profile_path):
                    print(f"Error: The profile '{profile}' does not exist.")
                    logger.error("Error: The profile '%s' does not exist.", profile)
                    sys.exit(1)
                else:
                    logger.info("Changing to profile '%s'.", profile)
                    change_profile(profile)
    # If the argument is 'remove'
    elif sys.argv[1] == "remove":
        logger.info("Running remove operations.")
        remove_printcfg()
    elif sys.argv[1] == "update":
        logger.info("Running update operations.")
        update_printcfg()
    elif sys.argv[1] == "status":
        logger.info("Running status operations.")
        show_status()
    elif sys.argv[1] == "help":
        logger.info("Running help operations.")
        show_help()
    else:
        logger.info("Running normal operations.")
        normal_ops()
