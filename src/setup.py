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

import os
import sys
import getpass
import subprocess

def start_script_as_root():
    # Get the current user name
    current_user = getpass.getuser()
    user_home = os.path.expanduser('~')
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

if __name__ == '__main__':
    start_script_as_root()