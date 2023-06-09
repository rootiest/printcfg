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

# This script reads the patch notes file and returns the highest version number.

import re
import sys


def find_highest_version(file_name):
    """Finds highest version in patch notes."""
    highest_version = None

    with open(file_name, "r", encoding="utf-8") as file:
        content = file.read()

    pattern = r"(\d+\.\d+\.\d+):"
    versions = re.findall(pattern, content)

    for version in versions:
        if highest_version is None or version > highest_version:
            highest_version = version

    return highest_version


# Test the function
f_name = sys.argv[1]
h_version = find_highest_version(f_name)
print(h_version)
