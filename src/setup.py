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
import os
import sys

# Service name and configuration file
SERVICE_NAME = "printcfg"
SERVICE_FILE = f"{os.path.expanduser('~')}/.config/systemd/user/{SERVICE_NAME}.service"
SERVICE_PATH = f"{os.path.expanduser('~')}/{SERVICE_NAME}/src"

# Path to the Python script
PYTHON_SCRIPT = f"{SERVICE_PATH}/{SERVICE_NAME}.py"
PYTHON_EXECUTABLE = sys.executable

if sys.argv[1] == "--install":
    if not PYTHON_SCRIPT:
        print("Please provide the path to the Python script as an argument.")
        sys.exit(1)

    # Create the service file
    service_content = f"""\
    [Unit]
    Description=Print Configuration Service

    [Service]
    ExecStart={PYTHON_EXECUTABLE} {PYTHON_SCRIPT}
    WorkingDirectory={os.path.dirname(SERVICE_PATH)}

    [Install]
    WantedBy=default.target
    """

    os.makedirs(os.path.dirname(SERVICE_FILE), exist_ok=True)
    with open(SERVICE_FILE, "w") as service:
        service.write(service_content)

    # Reload user systemd to recognize the new service
    os.system("systemctl --user daemon-reload")

    # Enable and start the service
    os.system(f"systemctl --user enable {SERVICE_NAME}")
    os.system(f"systemctl --user start {SERVICE_NAME}")

    # Check the status of the service
    os.system(f"systemctl --user status {SERVICE_NAME}")
else:
    print("Please provide the --install argument to install the service.")

