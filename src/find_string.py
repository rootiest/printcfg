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

import datetime
import getpass
import logging
import os
import sys

S_TEXT = sys.argv[1]
F_NAME = sys.argv[2]

logger: logging.Logger = logging.getLogger(__name__)

# Get the current user name
current_user = getpass.getuser()
user_home = os.path.expanduser("~")
# Set the logfile
logfile = f"{user_home}/printcfg/logs/find_string.log"

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

# Set the logging level
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler = logging.FileHandler(logfile)
handler.setFormatter(formatter)
logger.addHandler(handler)

# Log start of script
logger.info("Starting script: %s", __file__)


def check_file(file_name: str) -> bool:
    # Check if the file exists
    if not os.path.exists(file_name):
        logger.error("File not found: %s", file_name)
        return False
    # Check if the file is readable
    if not os.access(file_name, os.R_OK):
        logger.error("File is not readable: %s", file_name)
        return False
    # Check if the file is writable
    if not os.access(file_name, os.W_OK):
        logger.error("File is not writable: %s", file_name)
        return False
    return True


def find_string(search_text: str, file_name: str) -> str:
    """Search for a string in a file.

    Arguments:
        search_text: The text to search for.
        file_name: The name of the file to search.

    Returns:
        The rest of the line containing the search_text.
    """
    # Check if the file is accessible
    if not check_file(file_name):
        return "File not accessible."
    # Open the file in read mode
    with open(file_name, "r", encoding="utf-8") as sfile:
        # Read each line
        for line in sfile:
            # Strip the newline character at the end
            line = line.rstrip("\n")
            # Check if the search text is in the line
            if search_text in line:
                # Return the rest of the line
                # after the search text
                logger.info("Search text found: %s", search_text)
                logger.info("File name: %s", file_name)
                logger.info("Line: %s", line)
                logger.info("Rest of line: %s", line.split(search_text)[1])
                return line.split(search_text)[1]
    # If the search text was not found, return an error
    logger.error("Search text not found: %s", search_text)
    logger.info("File name: %s", file_name)
    return "Search text not found."


def string_exists(search_text: str, file_name: str) -> bool:
    """Search for a string in a file.

    Arguments:
        search_text: The text to search for.
        file_name: The name of the file to search.

    Returns:
        The rest of the line containing the search_text.
    """
    # Check if the file is accessible
    if not check_file(file_name):
        return False
    # Open the file in read mode
    with open(file_name, "r", encoding="utf-8") as filee:
        # Read each line
        for line in filee:
            # Strip the newline character at the end
            line = line.rstrip("\n")
            # Check if the search text is in the line
            if search_text in line:
                # Return the rest of the line
                # after the search text
                logger.info("Search text found: %s", search_text)
                logger.info("File name: %s", file_name)
                logger.info("Line: %s", line)
                return True
    # If the search text was not found, return an error
    logger.error("Search text not found: %s", search_text)
    logger.info("File name: %s", file_name)
    return False


# Check if the script was run from the command line
if __name__ == "__main__":
    # Log the current user
    logger.info("Current user: %s", current_user)
    # Log arguments
    logger.info("Arguments: %s", sys.argv)
    # Check for help argument
    if len(sys.argv) == 2 and sys.argv[1] == "--help" or sys.argv[1] == "-h":
        print("Usage: find_string.py <search_text> <file_name> [options]")
        print("Search for a string in a file.")
        print("Example: find_string.py 'hello world' hello.txt")
        print("Options:")
        print("  --exists, -e  Search for the string and return True or False.")
        print("  --help, -h   Show this help message and exit.")
        exit(0)
    if len(sys.argv) == 3:
        # Call the find_string function
        result = find_string(S_TEXT, F_NAME)
        # Return the result
        print(result)
    elif len(sys.argv) == 4 and sys.argv[3] == "--exists" or sys.argv[3] == "-e":
        # Call the find_string function
        if string_exists(S_TEXT, F_NAME):
            exists = "True"
        else:
            exists = "False"
        # Return the result
        print(exists)
    else:
        # Print an error message
        print("Usage: find_string.py <search_text> <file_name>")
        # Exit with an error code
        exit(1)
else:
    # Print an error message
    print("This script must be run from the command line.")
    # Exit with an error code
    sys.exit(1)
