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
import sys
import os
import getpass
import logging
import datetime

logger: logging.Logger = logging.getLogger(__name__)

# Get the current user name
current_user = getpass.getuser()
user_home = os.path.expanduser("~")
# Set the logfile
logfile = f"{user_home}/printcfg/logs/find_string.log"

# Check the date of the first log entry
# If it is older than 30 days, delete the logfile
if os.path.exists(logfile):
    with open(logfile, "r", encoding="utf-8") as logf:
        first_line = logf.readline()
        if first_line:
            first_line = first_line.split(" - ")[0]
            first_line = datetime.datetime.strptime(first_line, "%Y-%m-%d %H:%M:%S,%f")
            thirty_days_ago = datetime.datetime.now() - datetime.timedelta(days=30)
            if first_line < thirty_days_ago:
                os.remove(logfile)

# Set the logging level
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler = logging.FileHandler(logfile)
handler.setFormatter(formatter)
logger.addHandler(handler)

def find_string(search_text: str, file_name: str) -> str:
    """Search for a string in a file.

    Arguments:
        search_text: The text to search for.
        file_name: The name of the file to search.

    Returns:
        The rest of the line containing the search_text.
    """
    # Check if the file exists
    if not os.path.exists(file_name):
        logger.error(f"File not found: {file_name}")
        return "File not found."
    # Check if the file is readable
    if not os.access(file_name, os.R_OK):
        logger.error(f"File is not readable: {file_name}")
        return "File is not readable."
    # Check if the file is writable
    if not os.access(file_name, os.W_OK):
        logger.error(f"File is not writable: {file_name}")
        return "File is not writable."
    # Open the file in read mode
    with open(file_name, "r", encoding="utf-8") as file:
        # Read each line
        for line in file:
            # Strip the newline character at the end
            line = line.rstrip("\n")
            # Check if the search text is in the line
            if search_text in line:
                # Return the rest of the line
                # after the search text
                return line.split(search_text)[1]
    # If the search text was not found, return an error
    logger.error(f"Search text not found: {search_text}")
    return "Search text not found."

# Check if the script was run from the command line
if __name__ == "__main__":
    # Check if the script was run with the correct number of arguments
    if len(sys.argv) == 3:
        if sys.argv[1] == "--help" or sys.argv[1] == "-h":
            print("Usage: find_string.py <search_text> <file_name>")
            exit(0)
        else:
            # Get the search text and file name from the arguments
            s_text = sys.argv[1]
            f_name = sys.argv[2]
            # Call the find_string function
            result = find_string(s_text, f_name)
            # Return the result
            print(result)
    else:
        # Print an error message
        print("Usage: find_string.py <search_text> <file_name>")
        # Exit with an error code
        exit(1)
else:
    # Print an error message
    print("This script must be run from the command line.")
    # Exit with an error code
    exit(1)