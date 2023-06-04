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

# This code searches for a string in a file and replaces the whole line containing the string with a different string.
# The search is case sensitive.
# It will add the line if it does not exist.
# It will overwrite the file with the new contents.
# The file must already exist.
#
# Arguments:
#   search_text: The text to search for.
#   replace_text: The text to replace the search_text with.
#   file_name: The name of the file to search and replace.
#
# Returns:
#   A status indicating whether the change was successful.
#
# Usage:
#   python3 search_replace.py <search_text> <replace_text> <file_name>
#
# Example:
#   python3 search_replace.py "version" "version: 1.0.0" "patch_notes.txt"

import sys
import os
import getpass
import re
import logging

logger: logging.Logger = logging.getLogger(__name__)

# Get the current user name
current_user = getpass.getuser()
user_home = os.path.expanduser("~")
# Set the logfile
logfile = f"{user_home}/printcfg/logs/search_replace.log"

# Clear the logfile
if os.path.exists(logfile):
    with open(logfile, "w") as file:
        pass

# Set the logging level
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler = logging.FileHandler(logfile)
handler.setFormatter(formatter)
logger.addHandler(handler)


def simple_search_and_replace(search_text, replace_text, file_name):
    """Searches for the line containing the search_text and replaces the whole line with the replace_text and saves the updated file over the original.

    Args:
        search_text: The text to search for.
        replace_text: The text to replace the search_text with.
        file_name: The name of the file to search and replace.

    Returns:
        A status indicating whether the change was successful.
    """
    
    # Log the input
    logger.debug(
        "search_and_replace() called with: search_text=%s, replace_text=%s, file_name=%s",
        search_text,
        replace_text,
        file_name,
    )
    
    if search_text is None or replace_text is None or file_name is None:
        logger.error(
            "search_and_replace() failed due to invalid input: search_text=%s, replace_text=%s, file_name=%s",
            search_text,
            replace_text,
            file_name,
        )
        return False

    logger.debug("search_and_replace() opened the file %s", file_name)
    with open(file_name, "r") as f:
        lines = f.readlines()

    found = False
    for i, line in enumerate(lines):
        if search_text in line:
            lines[i] = replace_text + '\n'
            found = True
            logger.debug("search_and_replace() found the search_text %s", search_text)
            break

    if not found:
        logger.debug("search_and_replace() did not find the search_text %s", search_text)
        lines.insert(0, replace_text + "\n")
        logger.debug("search_and_replace() inserted the replace_text %s", replace_text)

    with open(file_name, "w") as f:
        f.writelines(lines)
        logger.debug("search_and_replace() wrote the file %s", file_name)

    return found


def search_and_replace(search_text: str, replace_text: str, file_name: str) -> bool:
    """Searches for the line containing the search_text and replaces the whole line with the replace_text and saves the updated file over the original.

    Args:
        search_text: The text to search for.
        replace_text: The text to replace the search_text with.
        file_name: The name of the file to search and replace.

    Returns:
        A status indicating whether the change was successful.
    """

    # Log the input
    logger.debug(
        "search_and_replace() called with: search_text=%s, replace_text=%s, file_name=%s",
        search_text,
        replace_text,
        file_name,
    )

    # Make sure the inputs are valid
    if search_text is None or replace_text is None or file_name is None:
        logger.error(
            "search_and_replace() failed due to invalid input: search_text=%s, replace_text=%s, file_name=%s",
            search_text,
            replace_text,
            file_name,
        )
        return False

    # Open the file
    logger.debug("search_and_replace() opened the file %s", file_name)
    with open(file_name, "r") as f:
        lines = f.readlines()

    # Search the file for the search_text
    found = False
    for i, line in enumerate(lines):
        if re.search(search_text, line):
            lines[i] = replace_text + "\n"
            found = True
            break

    # If the search_text wasn't found, insert the replace_text at the top
    if not found:
        lines.insert(0, replace_text + "\n")

    # Write the file
    logger.debug("search_and_replace() wrote the file %s", file_name)
    with open(file_name, "w") as f:
        f.writelines(lines)

    return True
    return found


# Check the number of arguments
if len(sys.argv) != 4:
    # Print the usage
    print("Usage:")
    print("  python3 search_replace.py <search_text> <replace_text> <file_name>")
    print("Example:")
    print('  python3 search_replace.py "version" "version: 1.0.0" "patch_notes.txt"')
    sys.exit(1)

search_text = sys.argv[1]
replace_text = sys.argv[2]
file_name = sys.argv[3]

status = simple_search_and_replace(search_text, replace_text, file_name)
if status:
    print("The change was successful.")
else:
    print("The text to search for was not found.")
