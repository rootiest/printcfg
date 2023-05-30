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

# This script searches for a line containing a specific text and replaces the whole line with a new text.
# If the text is not found, the new text is added to the beginning of the file.

# Usage: python3 search_replace.py <search_text> <replace_text> <file_name>

import sys
import re

def search_and_replace(search_text, replace_text, file_name):
    """Searches for the line containing the search_text and replaces the whole line with the replace_text and saves the updated file over the original.

    Args:
        search_text: The text to search for.
        replace_text: The text to replace the search_text with.
        file_name: The name of the file to search and replace.

    Returns:
        A status indicating whether the change was successful.
    """

    with open(file_name, "r") as f:
        lines = f.readlines()

    found = False
    for i, line in enumerate(lines):
        if re.search(search_text, line):
            lines[i] = replace_text + '\n'
            found = True
            break

    if not found:
        lines.insert(0, replace_text + "\n")

    with open(file_name, "w") as f:
        f.writelines(lines)

    return found

search_text = sys.argv[1]
replace_text = sys.argv[2]
file_name = sys.argv[3]

status = search_and_replace(search_text, replace_text, file_name)
if status:
    print("The change was successful.")
else:
    print("The text to search for was not found.")
