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

# This script collects some data and then triggers the service generator.

#!/usr/bin/env python3

import os
import sys
import getpass
import subprocess

    # Get the current user name
current_user = getpass.getuser()
user_home = os.path.expanduser('~')

def start_script_as_root():

    my_path = os.path.dirname(os.path.realpath(__file__))
    script_dir = os.path.dirname(my_path)
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
    script_path = f'{user_home}/printcfg/scripts/change_profile.sh'

    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return

    # Start the second script as root with the current user name as the first argument
    command = ['bash', script_path, profile]
    subprocess.run(command)
    
def remove_printcfg():
    # Define the path to the second script
    script_path = f'{user_home}/printcfg/scripts/remove_printcfg.sh'

    # Check if the second script exists
    if not os.path.isfile(script_path):
        print(f"Error: The script '{script_path}' does not exist.")
        return

    # Start the second script as root with the current user name as the first argument
    command = ['bash', script_path]
    subprocess.run(command)

if __name__ == '__main__':
    # Check the number of arguments
    if len(sys.argv) < 2:
        print('Error: This script requires one argument.')
        print('Usage: python3 setup.py <mode>')
        print('Modes: install, change, remove')
        sys.exit(1)
    # Check the argument
    if sys.argv[1] not in ['install', 'change', 'remove']:
        print('Error: The argument must be either install, change, or remove.')
        sys.exit(1)
    # If the argument is 'install' start the script as root
    if sys.argv[1] == 'install':
        start_script_as_root()
    # If the argument is 'change' check for a second argument
    elif sys.argv[1] == 'change':
        if len(sys.argv) != 3:
            print('Error: The change script requires two arguments.')
            print('Usage: python3 setup.py change <profile>')
            sys.exit(1)
        else:
            # Check if the profile exists
            profile = sys.argv[2]
            profile_path = f'{user_home}/printcfg/profiles/{profile}'
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
    else:
        print('Error: The argument must be either install, change, or remove.')
        sys.exit(1)