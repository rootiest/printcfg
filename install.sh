#!/bin/bash
# Copyright (C) 2023 Chris Laprade (chris@rootiest.com)
# 
# This file is part of Hephaestus.
# 
# Hephaestus is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Hephaestus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Hephaestus.  If not, see <http://www.gnu.org/licenses/>.

#####################################
##      Printcfg Install Script    ##
##      Version 3.3.0 2023-5-17    ##
#####################################

# This script will download and install the printcfg package from GitHub.
# Run the following:
# curl https://raw.githubusercontent.com/rootiest/printcfg/master/install.sh | bash

# Set the owner and repo name
owner="rootiest"
repo="printcfg"

# Check if the repo exists
if ! git ls-remote https://github.com/"$owner"/"$repo" >/dev/null; then
    echo "The repo does not exist."
    exit 1
fi

# Change to the home directory
cd ~

# Clone the repo
git clone https://github.com/"$owner"/"$repo"

# Change to the repo directory
cd "$repo"

# Install the dependencies
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# Run the setup script
if [ -f setup.py ]; then
    python setup.py install
fi

# Success!
echo "The repo has been successfully downloaded and installed."



