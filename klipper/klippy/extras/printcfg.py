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
'''
This is a simple plugin for Klipper that allows you to define some
configuration parameters that are specific to a particular print.  It
is intended to be used with either a macro or a post-processing script
to set the parameters for each print.

To use, add the following section to your printer.cfg file:

[printcfg]
enabled: True
led_name: "led_name"
park_x: 0
park_y: 0

The 'enabled' parameter is a master toggle that allows you to turn
printcfg on and off without having to remove the entire section from
your printer.cfg file.

The 'led_name' parameter specifies the name of the neopixel section
that you wish to use for notifications.  If you don't specify this
parameter, printcfg will not use the LEDs.

The 'park_x' and 'park_y' parameters specify the X and Y coordinates
that you wish to use for parking.  If you don't specify these
parameters, printcfg will not assign default parking coordinates.
'''
import math
import re
import logging
import os
import configfile

class PrintCFG:
    '''This class implements the printcfg plugin for Klipper'''
    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name()
        # Get configfile
        pconfig = self.printer.lookup_object('configfile')
        dir_name = os.path.dirname(os.path.realpath(__file__))
        filename = os.path.join(dir_name, 'printcfg.cfg')
        try:
            dconfig = pconfig.read_config(filename)
        except Exception:
            raise config.error("Cannot load config '%s'" % (filename,))
        for c in dconfig.get_prefix_sections(''):
            self.printer.load_object(dconfig, c.get_name())
        # Master toggle
        self.enabled = config.getboolean('enabled')
        # LED control
        self.leds = config.get('led_name', default=None)
        if self.leds is not None:
            try:
                self.led_type = "neopixel"
                self.led_object = self.led_type + " " + self.leds
                self.printer.lookup_object(self.led_object)
            except Exception:
                try:
                    self.led_type = "dotstar"
                    self.led_object = self.led_type + " " + self.leds
                    self.printer.lookup_object(self.led_object)
                except Exception:
                    try:
                        self.led_type = "led"
                        self.led_object = self.led_type + " " + self.leds
                        self.printer.lookup_object(self.led_object)
                    except Exception:
                        raise config.error(
                            "Could not find 'neopixel', 'dotstar' or 'led' section '%s' expected by PrintCFG"
                            % (self.leds))
        else:
            self.led_object = None
        # Parking position
        xp = config.getfloat('park_x', default=None)
        if xp is not None:
            if config.has_section('stepper_x'):
                xconfig = config.getsection('stepper_x')
                xmin =  xconfig.getfloat('position_min', 0.,
                                                note_valid=False)
                xmax =  xconfig.getfloat('position_max', 0.,
                                                note_valid=False)
                if xmin <= xp <= xmax:
                    self.x_park = xp
                else:
                    raise config.error("printcfg.park_x value %0.f is not between %0.f and %0.f" % (xp, xmin, xmax))
        else:
            if config.has_section('stepper_x'):
                xconfig = config.getsection('stepper_x')
                self.x_park = xconfig.getfloat('position_max', 0.,
                                                note_valid=False)
            else:
                raise config.error("Could not find stepper_x section expected by PrintCFG")
        yp = config.getfloat('park_y', default=None)
        if yp is not None:
            if config.has_section('stepper_y'):
                yconfig = config.getsection('stepper_y')
                ymin =  yconfig.getfloat('position_min', 0.,
                                                note_valid=False)
                ymax =  yconfig.getfloat('position_max', 0.,
                                                note_valid=False)
                if ymin <= yp <= ymax:
                    self.y_park = yp
                else:
                    raise config.error("printcfg.park_y value %0.f is not between %0.f and %0.f" % (yp, ymin, ymax))
        else:
            if config.has_section('stepper_y'):
                yconfig = config.getsection('stepper_y')
                self.y_park = xconfig.getfloat('position_max', 0.,
                                                note_valid=False)
            else:
                raise config.error("Could not find stepper_y section expected by PrintCFG")
        # Extra fans
        self.extra_fans = config.get('extra_fans', default=None)
        # Gcode commands
        self.gcode = self.printer.lookup_object('gcode')
        self.gcode.register_command('SETUP_PRINTCFG', self.cmd_SETUP_PRINTCFG,
                                    desc=self.cmd_SETUP_PRINTCFG_help)
        self.gcode.register_command('SETUP_EXTRA_FANS', self.cmd_SETUP_EXTRA_FANS,
                                    desc=self.cmd_SETUP_EXTRA_FANS_help)
        self.update_status()
        
    def get_status(self, eventtime=None):
        return self.status
    def update_status(self):
        self.status = {
            "enabled": self.enabled,
            "leds": self.leds,
            "led_type": self.led_type,
            "led_object": self.led_object,
            "park_x": self.x_park,
            "park_y": self.y_park,
            "extra_fans:": self.extra_fans
        }
    cmd_SETUP_EXTRA_FANS_help = "Set up PrintCFG Extra Fans"
    def cmd_SETUP_EXTRA_FANS(self, gcmd):
        logging.info("SETUP_EXTRA_FANS %s", self.name)
        self.setup()
        self.gcode.run_script_from_command("_setup_extra_fans")

    cmd_SETUP_PRINTCFG_help = "Set up PrintCFG Module"
    def cmd_SETUP_PRINTCFG(self, gcmd):
        logging.info("SETUP_PRINTCFG %s", self.name)
        self.setup()
        self.gcode.run_script_from_command("_printcfg_wizard")

    def setup(self, leds=None):
        if leds is not None:
            self.leds = leds
            self.led_object = "neopixel " + self.leds
            logging.info("Changed LEDs to %s", self.leds)
        else:
            if self.leds is None:
                raise config.error("No LEDs specified")
            else:
                logging.info("Using LEDs %s", self.leds)

def load_config(config):
    return PrintCFG(config)
