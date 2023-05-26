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

#!/usr/bin/env python3

# This is the printcfg service.

import subprocess
import os

# Path to the shell script
SHELL_SCRIPT = "/home/pi/printcfg/scripts/setup.sh"

# Run the shell script at startup
subprocess.Popen(["/bin/bash", SHELL_SCRIPT])

# Continuously run in the background
while True:
    # Do any other tasks or operations here
    # You can add your code logic within this loop
    
    # Sleep for a certain duration (e.g., 1 second)
    os.system("sleep 1")
