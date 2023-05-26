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

# Set the repo name
REPO = 'printcfg'

# Get the current user name
current_user = getpass.getuser()
user_home = os.path.expanduser('~')
profile_path = f"{user_home}/printer_data/user_profile.cfg"
setup_script = f"{user_home}/printcfg/scripts/setup.sh"

def find_profile(path):
    # Find the profile name (Eg: '# Profile: default' = 'default')
    with open(path, 'r') as file:
            for line in file:
                if line.startswith('# Profile: '):
                    # Return the profile name
                    return line[11:].strip()

def normal_ops():
    # Run the shell script at startup
    subprocess.Popen(["/bin/bash", setup_script])
    print (f"Running in the background as {current_user}")
    # Continuously run in the background
    while True:
        # Sleep for a minute
        os.system("sleep 60")

def generate_service():
    # Define the path to the second script
    script_dir = f'{user_home}/{REPO}/'
    mode = sys.argv[1]
    # Define the path to the second script
    script_path = f'{script_dir}/src/gen_service.py'
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Start the second script as root with the current user name as the first argument
    command = ['sudo', 'python3', script_path, current_user, user_home, mode]
    subprocess.run(command)

def change_profile(profile):
    # Define the path to the second script
    script_path = f'{user_home}/{REPO}/scripts/change_profile.sh'
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Start the change profile script
    command = ['bash', script_path, profile]
    subprocess.run(command)
    
def update_printcfg():
    # Define the path to the second script
    script_path = f'{user_home}/{REPO}/scripts/install.sh'
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Find the current profile
    profile = find_profile(profile_path)
    # Start the update script
    command = ['bash', script_path, profile]
    
def remove_printcfg():
    # Define the path to the second script
    script_path = f'{user_home}/{REPO}/scripts/remove_{REPO}.sh'
    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return
    # Start the second script as root with the current user name as the first argument
    command = ['bash', script_path]
    subprocess.run(command)

if __name__ == '__main__':
    # Check if there are any arguments
    if len(sys.argv) < 2:
        normal_ops()
        sys.exit(1)
    # Check the argument
    if sys.argv[1] not in ['install', 'change', 'remove', 'update', 'default']:
        print('Error: The argument must be either install, change, remove, update, or default.')
        sys.exit(1)
    # If the argument is 'install' start the script as root
    if sys.argv[1] == 'install':
        generate_service()
    # If the argument is 'change' check for a second argument
    elif sys.argv[1] == 'change':
        if len(sys.argv) != 3:
            print('Error: The change script requires two arguments.')
            print(f'Usage: python3 {REPO}.py change <profile>')
            sys.exit(1)
        else:
            # Check if the profile exists
            profile = sys.argv[2]
            profile_path = f'{user_home}/{REPO}/profiles/{profile}'
            print(f"Changing to profile '{profile}'")
            # If the profile is 'backup' then skip the check
            if profile == 'backup':
                change_profile(profile)
            else:
                # If the profile path does not exist, exit
                if not os.path.isdir(profile_path):
                    print(f"Error: The profile '{profile}' does not exist.")
                    sys.exit(1)
                else:
                    change_profile(profile)
    # If the argument is 'remove'
    elif sys.argv[1] == 'remove':
        remove_printcfg()
    elif sys.argv[1] == 'update':
        update_printcfg()
        
    else:
        normal_ops()