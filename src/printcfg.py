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

""" PrintCFG Klipper Suite - 

    A configuration manager
    and macro suite 
    for Klipper printers.
    
"""
import datetime
import getpass
import logging
import os
import subprocess
import sys

logger: logging.Logger = logging.getLogger(__name__)

# Set the repo name
REPO = "printcfg"
# Set arguments
ARGUMENTS_LIST = [
    "help",
    "install",
    "restart",
    "change",
    "remove",
    "update",
    "repair",
    "branch",
    "status",
]
# Get the current user name
current_user = getpass.getuser()
user_home = os.path.expanduser("~")
profile_path = f"{user_home}/printer_data/config/user_profile.cfg"
setup_script = f"{user_home}/{REPO}/scripts/setup.sh"

# Set the logfile
logfile = f"{user_home}/{REPO}/logs/{REPO}.log"

# Check the date of the first log entry
# If it is older than 30 days, delete the logfile
if os.path.exists(logfile):
    with open(logfile, "r", encoding="utf-8") as file:
        first_line = file.readline()
        if first_line:
            first_line = first_line.split(" - ")[0]
            first_date = datetime.datetime.strptime(first_line, "%Y-%m-%d %H:%M:%S,%f")
            thirty_days_ago = datetime.datetime.now() - datetime.timedelta(days=30)
            if first_date < thirty_days_ago:
                os.remove(logfile)

# Check if the logfile exists
log_dir = f"{user_home}/{REPO}/logs/"
if not os.path.exists(log_dir):
    try:
        # Create the log directory
        os.makedirs(log_dir)
    except OSError as err:
        print(f"Error creating log directory: {err}")
    # Create the logfile
    try:
        with open(logfile, "w", encoding="utf-8") as file:
            pass
        logging.info("Created log file: %s", logfile)
    except OSError as err:
        logging.error("Error creating log file: %s", err)

# Set the logging level
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler = logging.FileHandler(logfile)
handler.setFormatter(formatter)
logger.addHandler(handler)


def show_help():
    """Show the help message."""
    logger.info("Showing help message...")
    print(f"Usage: {sys.argv[0]} [install|change|remove|update|help]")
    print(f"  install: Install the {REPO} service")
    print(f"  restart: Restart the {REPO} service")
    print("  change: Change the current profile")
    print(f"  branch: Change the current {REPO} branch")
    print(f"  remove: Remove {REPO} service")
    print(f"  update: Update {REPO}")
    print(f"  status: Show the status of the {REPO} service")
    print(f"  repair: Repair the {REPO} service")
    print("  help: Show this help message")
    logger.info("Help message shown.")
    sys.exit(0)


def is_service_active(service: str):
    """Determine whether a systemctl system service is active."""
    # Check if the service exists
    logger.debug("Checking if service exists: %s", service)
    if not os.path.exists(f"/etc/systemd/system/{service}.service"):
        logger.debug("Service does not exist: %s", service)
        return False
    else:
        logger.debug("Service exists: %s", service)
        # Check if service is enabled
        logger.debug("Checking if service is enabled: %s", service)
        if subprocess.run(
            ["systemctl", "is-enabled", service], capture_output=True, check=True
        ).stdout.decode("utf-8") == "enabled\n":
            logger.debug("Service is enabled: %s", service)
            # Check if service is active
            logger.debug("Checking if service is active: %s", service)
            if subprocess.run(
                ["systemctl", "is-active", service], capture_output=True, check=True
            ).stdout.decode("utf-8") == "active\n":
                logger.debug("Service is active: %s", service)
                return True
            else:
                logger.debug("Service is not active: %s", service)
                return False


def load_config():
    """
        Load the printcfg.conf config file.
        And output its contents.
    """
    logger.info("Loading config file...")
    # Set the config file path
    config_path = f"{user_home}/{REPO}/printcfg.conf"
    # Log and print the config file path
    logger.debug("Config file path: %s", config_path)
    print(f"### START OF {config_path} ###")
    # Check if the config file exists
    if not os.path.exists(config_path):
        logger.error("Config file not found: %s", config_path)
        raise FileNotFoundError(f"Config file not found: {config_path}")
    # Load the config file
    with open(config_path, "r", encoding="utf-8") as config_file:
        for line in config_file:
            print(line, end="")
            logger.debug("Config line: %s", line)
    print(f"### END OF {config_path} ###")
    logger.info("Config file loaded.")



def find_profile(path: str):
    """Find the profile name in the given file."""
    logger.debug("Searching for profile name in file: %s", path)
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
    """Run the script normally."""
    logger.info("Starting normal operations...")
    print(f"Starting {REPO}...")
    try:
        profile_name = find_profile(profile_path)
    except ValueError as errnorm:
        logger.error("Error: %s", str(errnorm))
        profile_name = "default"
        logger.info("Using default profile.")
    try:
        # Run the shell script at startup
        subprocess.Popen(["/bin/bash", setup_script, profile_name])
        logger.info("Startup script complete.")
    except subprocess.CalledProcessError as errsetscript:
        # Log the error
        logger.error("Error running startup script: %s", str(errsetscript))
        # Exit with error
        sys.exit(1)
    # Exit gracefully
    logger.info("Startup script complete.")
    print(f"{REPO} started.")
    sys.exit(0)


def generate_service():
    """Generate the printcfg service."""
    logger.info("Generating %s service...", REPO)
    print(f"Generating {REPO} service...")
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
    command = ["sudo", "python3", script_path, current_user, user_home, mode]
    logger.debug("Executing command: %s", command)
    try:
        result = subprocess.run(command, capture_output=True, check=False)
    except subprocess.CalledProcessError as errgen:
        print("Error: The subprocess returned an error.")
        print(errgen.stderr)
        logger.error("Error: The subprocess returned an error: %s", errgen.stderr)
        return
    logger.debug("Command output: %s", result.stdout.decode("utf-8"))
    if result.returncode != 0:
        print(f"Error: The command '{command}' failed with code {result.returncode}.")
        logger.error(
            "Error: The command '%s' failed with code %s.", command, result.returncode
        )
        print(f"Output from command: {result.stdout.decode('utf-8')}")
        print(f"Error from command: {result.stderr.decode('utf-8')}")
        return
    # Exit gracefully
    logger.info("%s service generated successfully.", REPO)
    print(f"{REPO} service generated successfully.")
    sys.exit(0)


def change_profile(profile_name: str):
    """Change the profile."""
    logger.info("Changing profile to %s...", profile_name)
    print(f"Changing profile to {profile_name}...")
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
    except subprocess.CalledProcessError as errprofile:
        print("Error: The subprocess returned an error.")
        print(errprofile.stderr)
        logger.error("Error: The subprocess returned an error: %s", errprofile.stderr)
    # Exit gracefully
    logger.info("Profile changed to %s successfully.", profile_name)
    print(f"Profile changed to {profile_name} successfully.")
    sys.exit(0)


def update_printcfg():
    """Update printcfg."""
    logger.info("Updating %s...", REPO)
    print(f"Updating {REPO}...")
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
    except subprocess.CalledProcessError as errr:
        print("Error: The subprocess returned an error.")
        print(errr.stderr)
        logger.error("Error: The subprocess returned an error: %s", errr.stderr)
    # Exit gracefully
    logger.info("%s updated successfully.", REPO)
    print(f"{REPO} updated successfully.")
    sys.exit(0)


def restart_service(service_name: str):
    """Restarts a systemctl service.

    Args:
        service_name: The name of the systemctl service to restart.

    Returns:
        True if the service was restarted successfully, False otherwise.
    """
    logger.info("Restarting %s service...", service_name)
    print(f"Restarting {service_name} service...")
    command = ["systemctl", "restart", f"{service_name}.service"]
    logger.debug("Executing command: %s", command)
    try:
        subprocess.check_call(command)
        logger.info("Service '%s' restarted successfully.", service_name)
        print(f"Service '{service_name}' restarted successfully.")
        return True
    except subprocess.CalledProcessError as errserv:
        logger.error("Error restarting %s service: %s", service_name, errserv)
        print(f"Error restarting {service_name} service: {errserv}")
        return False


def change_branch(branch_name: str):
    """Changes the branch of the printcfg repo."""
    logger.info("Changing to branch '%s'.", branch_name)
    print(f"Changing to branch '{branch_name}'.")
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/install.sh"
    logger.debug("Script: %s", script_path)
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Find the current profile
    profile_name = find_profile(profile_path)
    # Start the change branch script
    command = ["bash", script_path, profile_name, branch_name]
    logger.debug("Executing command: %s", command)
    logger.debug(
        "Changing to branch '%s' with profile '%s'.", branch_name, profile_name
    )
    print(f"Changing to branch '{branch_name}' with profile '{profile_name}'.")
    try:
        subprocess.run(command, check=False)
    except subprocess.CalledProcessError as errbranch:
        print("Error: The subprocess returned an error.")
        print(errbranch.stderr)
        logger.error("Error: The subprocess returned an error: %s", errbranch.stderr)
    # Exit gracefully
    logger.info("Succesfully changed to branch '%s'.", branch_name)
    print(f"Succesfully changed to branch '{branch_name}'.")
    sys.exit(0)


def repair_printcfg():
    """Repairs printcfg."""
    logger.info("Repairing %s...", REPO)
    print(f"Repairing {REPO}...")
    # Define the path to the second script
    script_path = f"{user_home}/{REPO}/scripts/setup.sh"
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Find the current profile
    profile_name = find_profile(profile_path)
    # Start the update script
    command = ["bash", script_path, profile_name, "force"]
    logger.debug("Executing command: %s", command)
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as errepair:
        print("Error: The subprocess returned an error.")
        print(errepair.stderr)
        logger.error("Error: The subprocess returned an error: %s", errepair.stderr)
    # Exit gracefully
    logger.info("Repairing %s completed successfully.", REPO)
    print(f"Repairing {REPO} completed successfully.")
    sys.exit(0)


def remove_printcfg():
    """Remove printcfg from the system."""
    logger.info("Removing %s...", REPO)
    print(f"Removing {REPO}...")
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
    except subprocess.CalledProcessError as erremove:
        print("Error: The subprocess returned an error.")
        print(erremove.stderr)
        logger.error("Error: The subprocess returned an error: %s", erremove.stderr)
    # Exit gracefully
    logger.info("%s removed successfully.", REPO)
    print(f"{REPO} removed successfully.")
    sys.exit(0)


def show_status(service_name: str):
    """Show the status of a systemctl service.

    Args:
        service_name: The name of the systemctl service to restart.

    Returns:
        True if the status was displayed successfully, False otherwise.
    """
    logger.info("Showing status of %s service...", service_name)
    print(f"Showing status of {service_name} service...")
    # Get the systemctl status
    command = ["systemctl", "status", f"{service_name}.service"]
    logger.debug("Executing command: %s", command)
    try:
        result = subprocess.run(command, capture_output=True, check=False)
    except subprocess.CalledProcessError as errstat:
        print("Error: The subprocess returned an error.")
        print(errstat.stderr)
        logger.error("Error: The subprocess returned an error: %s", errstat.stderr)
        return False
    logger.debug("Command output: %s", result.stdout.decode("utf-8"))
    if result.returncode != 0:
        print(f"Error: The command '{command}' failed with code {result.returncode}.")
        logger.error(
            "Error: The command '%s' failed with code %s.", command, result.returncode
        )
        print(f"Output from command: {result.stdout.decode('utf-8')}")
        print(f"Error from command: {result.stderr.decode('utf-8')}")
        return False
    # Print the status
    print(result.stdout.decode("utf-8"))
    logger.info("Showing config file...")
    print(f"Current {REPO} configuration:")
    load_config()
    print("")
    # Check if printcfg service is active
    if not is_service_active(service_name):
        print(f"Error: {service_name} service is not active.")
        logger.error("%s service is not active.", service_name)
        return False
    else:
        print(f"{service_name} service is active.")
        logger.info("%s service is active.", service_name)
    # Exit gracefully
    logger.info("Status shown successfully.")
    return True


if __name__ == "__main__":
    # Check if there are any arguments
    if len(sys.argv) < 2:
        logger.info("No arguments provided, running normal operations.")
        normal_ops()
        sys.exit(1)
    # Check the argument
    if sys.argv[1] not in ARGUMENTS_LIST:
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
        show_status(REPO)
    elif sys.argv[1] == "restart":
        logger.info("Running restart operations.")
        restart_service(REPO)
    elif sys.argv[1] == "repair":
        logger.info("Running repair operations.")
        repair_printcfg()
    elif sys.argv[1] == "branch":
        logger.info("Running branch operations.")
        # Make sure the branch was provided
        if len(sys.argv) != 3:
            print("Error: The branch script requires two arguments.")
            print(f"Usage: python3 {REPO}.py branch <branch>")
            logger.error("Error: The branch script requires two arguments.")
            sys.exit(1)
        else:
            branch_arg = sys.argv[2]
            change_branch(branch_arg)
    elif sys.argv[1] == "help":
        logger.info("Running help operations.")
        show_help()
    else:
        logger.info("Running normal operations.")
        normal_ops()

    # Exit gracefully
    logger.info("%s completed successfully.", REPO)
    exit(0)
