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
"""
This is a simple plugin for Klipper that allows you to reference any
saved state created by the SAVE_GCODE_STATE command.  It is intended
to extend on the functionality of that native component by allowing you
to reference the list of saved states and their associated properties.
"""
import math
import re
import logging
import os
import configfile


class SavedStates:
    """This class implements the saved_states plugin for Klipper"""

    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name()
        self.saved_states = {}
        self.gcode = self.printer.lookup_object("gcode")
        self.gcode.register_command(
            "QUERY_STATE", self.cmd_QUERY_STATE, desc=self.cmd_QUERY_STATE_help
        )
        self.update_status()

    def update_status(self):
        """Update the status of the saved states"""
        self.gcode_move = self.printer.lookup_object("gcode_move")
        self.states = self.gcode_move.saved_states
        self.status = {"states": self.states}

    cmd_QUERY_STATE_help = "Update current saved states"

    def cmd_QUERY_STATE(self, gcmd):
        self.gcode.respond_info("Saved states updated.")
        self.update_status()
        self.gcode.respond_info("Saved states: {}".format(self.saved_states))


def load_config(config):
    return SavedStates(config)
