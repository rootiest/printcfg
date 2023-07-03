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

"""Generate a service file for printcfg."""
import datetime
import logging
import os
import sys

logger: logging.Logger = logging.getLogger(__name__)

if len(sys.argv) < 3:
    USER = os.environ["USER"]
    GROUP = os.environ["USER"]
    HOME = os.path.expanduser("~")
else:
    USER = sys.argv[1]
    GROUP = sys.argv[1]
    HOME = sys.argv[2]

# Set the logfile
logfile = f"{HOME}/printcfg/logs/gen_service.log"

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
log_dir = f"{HOME}/printcfg/logs/"
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

# Log start of script (include script name)
logger.info("Starting %s", os.path.basename(__file__))

# Service name and configuration file
SERVICE_NAME = "printcfg"
SERVICE_LINK = f"/etc/systemd/system/{SERVICE_NAME}.service"
SERVICE_PATH = f"{HOME}/{SERVICE_NAME}"
SERVICE_FILE = f"{HOME}/{SERVICE_NAME}/src/{SERVICE_NAME}.service"

# Path to the Python script
PYTHON_SCRIPT = f"{SERVICE_PATH}/src/{SERVICE_NAME}.py"
PYTHON_EXECUTABLE = sys.executable

# Log start of service generation
logger.info("Generating service file...")

if len(sys.argv) < 2 and len(sys.argv) > 0:
    MODE = sys.argv[1]
elif len(sys.argv) < 0:
    print("Please provide the 'install' argument to install the service.")
elif len(sys.argv) == 4 and sys.argv[3] == "install":
    # Create the service file
    service_content = f"""\
        [Unit]
        Description=Print Configuration Service
        Requires=klipper.service
        After=klipper.service

        [Service]
        Mode=oneshot
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
    logger.info("Installing service...")
    print(f"Service file: {SERVICE_FILE}")
    logger.info("Service file: %s", SERVICE_FILE)
    print(f"Python script: {PYTHON_SCRIPT}")
    logger.info("Python script: %s", PYTHON_SCRIPT)
    print(f"Python executable: {PYTHON_EXECUTABLE}")
    logger.info("Python executable: %s", PYTHON_EXECUTABLE)
    print(f"Working directory: {os.path.dirname(SERVICE_PATH)}")
    logger.info("Working directory: %s", os.path.dirname(SERVICE_PATH))
    os.makedirs(os.path.dirname(SERVICE_FILE), exist_ok=True)
    # Check if the service file exists
    if os.path.exists(SERVICE_FILE):
        logger.info("Service file '%s' already exists, overwriting.", SERVICE_FILE)
        print("Service file '{SERVICE_FILE}' already exists, overwriting.")
        # Remove the existing service file
        os.remove(SERVICE_FILE)
    with open(SERVICE_FILE, "w", encoding="utf-8") as service:
        service.write(service_content)
    # Set the appropriate permissions for the service configuration file
    os.chmod(SERVICE_FILE, 0o644)
    # Check if the symbolic link to the service file exists
    if os.path.exists(SERVICE_LINK):
        logger.info("Symbolic link '%s' already exists, overwriting.", SERVICE_LINK)
        print(f"Symbolic link '{SERVICE_LINK}' already exists, overwriting.")
        # Remove the existing symbolic link
        os.remove(SERVICE_LINK)
    # Symbolic link to the service file
    os.symlink(SERVICE_FILE, SERVICE_LINK)
    # Reload systemd to recognize the new service
    os.system("systemctl daemon-reload")
    # Check if the service exists and is started
    if os.system(f"systemctl is-active --quiet {SERVICE_NAME}") == 0:
        logger.info("Service '%s' is already running.", SERVICE_NAME)
        print(f"Service '{SERVICE_NAME}' is already running.")
        # Restart the service
        os.system(f"systemctl restart {SERVICE_NAME}")
    else:
        # Enable and start the service
        os.system(f"systemctl enable {SERVICE_NAME}")
        os.system(f"systemctl start {SERVICE_NAME}")
    # Check the status of the service
    os.system(f"systemctl status {SERVICE_NAME}")
    # Check if the symbolic link to the executable exists
    if os.path.exists(f"/usr/local/bin/{SERVICE_NAME}"):
        logger.info(
            "Symbolic link '/usr/local/bin/%s' already exists, overwriting.",
            SERVICE_NAME,
        )
        print(
            f"Symbolic link '/usr/local/bin/{SERVICE_NAME}' already exists, overwriting."
        )
        # Remove the existing symbolic link
        os.remove(f"/usr/local/bin/{SERVICE_NAME}")
    # Symbolic link to the executable
    os.symlink(PYTHON_SCRIPT, f"/usr/local/bin/{SERVICE_NAME}")
    # Set the appropriate permissions for the executable
    os.chmod(f"/usr/local/bin/{SERVICE_NAME}", 0o755)
else:
    print("Please provide the 'install' argument to install the service.")
    sys.exit(1)
