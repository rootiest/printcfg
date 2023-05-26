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

# This script generates a service file for printcfg.

#!/usr/bin/env python3
import os
import sys
import subprocess

if len(sys.argv) < 3:
    USER = os.environ["USER"]
    GROUP = os.environ["USER"]
    HOME= os.path.expanduser('~')
else:
    USER = sys.argv[1]
    GROUP = sys.argv[1]
    HOME = sys.argv[2]

# Service name and configuration file
SERVICE_NAME = "printcfg"
SERVICE_FILE = f"/etc/systemd/system/{SERVICE_NAME}.service"
SERVICE_PATH = f"{HOME}/{SERVICE_NAME}"

# Path to the Python script
PYTHON_SCRIPT = f"{SERVICE_PATH}/src/{SERVICE_NAME}.py"
PYTHON_EXECUTABLE = sys.executable

if len(sys.argv) < 2 and len(sys.argv) > 0:
    MODE = sys.argv[1]
elif len(sys.argv) < 0:
    print("Please provide the --install argument to install the service.")
else:
    if sys.argv[3] == "--install":
        if not PYTHON_SCRIPT:
            print("Please provide the path to the Python script as an argument.")
            sys.exit(1)

        # Create the service file
        service_content = f"""\
            [Unit]
            Description=Print Configuration Service
            Requires=klipper.service
            After=klipper.service

            [Service]
            User={USER}
            Group={GROUP}
            RemainAfterExit=yes
            ExecStart={PYTHON_EXECUTABLE} {PYTHON_SCRIPT}
            WorkingDirectory={os.path.dirname(SERVICE_PATH)}
            TimeoutStartSec=0

            [Install]
            WantedBy=default.target
            """
        
        print("Installing service...")
        print(f"Service file: {SERVICE_FILE}")
        print(f"Python script: {PYTHON_SCRIPT}")
        print(f"Python executable: {PYTHON_EXECUTABLE}")
        print(f"Working directory: {os.path.dirname(SERVICE_PATH)}")

        os.makedirs(os.path.dirname(SERVICE_FILE), exist_ok=True)
        with open(SERVICE_FILE, "w") as service:
            service.write(service_content)

        # Set the appropriate permissions for the service configuration file
        os.chmod(SERVICE_FILE, 0o644)
            
        # Switch to the root user
        

        # Reload systemd to recognize the new service
        os.system("systemctl daemon-reload")

        # Enable and start the service
        os.system(f"systemctl enable {SERVICE_NAME}")
        os.system(f"systemctl start {SERVICE_NAME}")

        # Check the status of the service
        os.system(f"systemctl status {SERVICE_NAME}")
    else:
        print("Please provide the --install argument to install the service.")
        sys.exit(1)