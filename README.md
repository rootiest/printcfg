<!--
 Copyright (C) 2023 Chris Laprade (chris@rootiest.com)

 This file is part of printcfg.

 printcfg is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 printcfg is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with printcfg.  If not, see <http://www.gnu.org/licenses/>.
-->

<!--
#####################################
##      Printcfg Documentation     ##
##      Version 4.0.0 2023-6-1     ##
#####################################
-->

![header](docs/pretty_header.png)

# PrintCFG Klipper Suite

This set of macros is a full suite of features for Klipper.

It is designed to be fully customizable to fit any printer or configuration. All without having to edit or understand the macros themselves. All configuration for the macros is done in the [user_profile.cfg](profiles/default/variables.cfg) file.

[Documentation is available in the Wiki](https://github.com/rootiest/printcfg/wiki)

## Features

- Start/End Gcode Macros
- Bed Meshing (including adaptive meshing)
- Smart Filament Change Macros
- Fan Control Macros (bed fans, nevermore filter/exhaust fans, etc)
- Door Panel Button Macros
- Custom Homing Behavior (change homing position live, sensorless homing, etc)
- Custom Heater Control
- Custom LED Control
- Audio Status Notifications
- Custom Parking Behavior
- Nozzle Brushing and Prime Line Macros
- Chamber Sensor/Fan/Heater Control
- Filter usage tracking and reminders
- and more!

All of this can be configured and used with absolutely no knowledge of creating macros. Simply set configuration values like you do for other klipper configurations and the macros will automatically adjust to your settings.
