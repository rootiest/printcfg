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
import configfile

class PrintCFG:
    def __init__(self, config):
        self.printer = config.get_printer()
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
        #self.name = config.get_name().split()[-1]
        # Master toggle
        self.enabled = config.getboolean('enabled', default=True)
        # LED control
        self.leds = config.getfloat('led_name', default=None)
        self.led_object = "neopixel " + self.leds
        if not self.printer.lookup_object(self.led_object):
            raise config.error(
                "Could not find neopixel section '[%s]' required by printcfg"
                % (self.led_object))
        # Parking position
        self.x_park = config.getfloat('park_x', minval=0.)
        if config.has_section('stepper_x'):
            xconfig = config.getsection('stepper_x')
            self.x_park = xconfig.getfloat('position_max', 0.,
                                               note_valid=False)
        else:
            raise config.error("Could not find stepper_x section required by printcfg")
        self.y_park = config.getfloat('park_y', minval=0.)
        if config.has_section('stepper_y'):
            yconfig = config.getsection('stepper_y')
            self.y_park = xconfig.getfloat('position_max', 0.,
                                               note_valid=False)
        else:
            raise config.error("Could not find stepper_y section required by printcfg")
        self.gcode = self.printer.lookup_object('gcode')
        self.gcode.register_command('SETUP_PRINTCFG', self.cmd_SETUP_PRINTCFG,
                                    desc=self.cmd_SETUP_PRINTCFG_help)
        

    cmd_SETUP_PRINTCFG_help = "Apply autotuning configuration to TMC stepper driver"
    def cmd_SETUP_PRINTCFG(self, gcmd):
        logging.info("SETUP_PRINTCFG %s", self.name)
        self.setup()

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


def load_config_prefix(config):
    return PrintCFG(config)
