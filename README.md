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


# PrintCFG Klipper Suite

- [PrintCFG Klipper Suite](#printcfg-klipper-suite)
  - [!!! WARNING: THIS IS STILL A WORK IN PROGRESS !!!](#-warning-this-is-still-a-work-in-progress-)
  - [Overview](#overview)
  - [Installation](#installation)
    - [What the install script does](#what-the-install-script-does)
  - [Configuration](#configuration)
  - [Using the suite](#using-the-suite)

## !!! WARNING: THIS IS STILL A WORK IN PROGRESS !!!

 > I am currently running this suite on my personal machine so I consider it to be ready for brave testers to play around with. Expect to encounter issues! But please tell me about them so I can fix them in a later revision!

## Overview

This set of macros is a full suite of features for Klipper.

It requires a fair bit of configuration, but everything can be configured by setting the values of variables in the [user_profile.cfg](profiles/default.cfg) file.

You can also change any of these settings at runtime using `SET_GCODE_VARIABLE` commands.

These `SET_GCODE_VARIABLE` commands are also used to pass values from the slicer instead of the traditional method using parameters.

## Installation

To install the suite using the default presets, run the following command:

    curl https://raw.githubusercontent.com/rootiest/printcfg/master/scripts/install.sh | bash

You can also specify a preset profile for a more printer-specific default config:

    curl https://raw.githubusercontent.com/rootiest/printcfg/master/scripts/install.sh | bash -s -- hephaestus

### What the install script does

The install script will clone the repo into your home directory in a folder named `printcfg`.

The following line will be added to your `printer.cfg` file:

    [include printcfg/print_config.cfg]

This tells Klipper to include the printcfg config file. The other files will be included from there.

The following line will be added to your `moonraker.conf` file:

    [include printcfg/moonraker-printcfg.conf]

This adds some moonraker configuration, specifically the `update_manager` for printcfg updates.

## Configuration

The vast majority of the configuration is done via the `_printcfg` macro in `user_profile.cfg`.

Additional configuration may be required via the `user_config.cfg` file.

Please only modify files that begin with `user_` so that the update system can successfully merge changes.

You will be notified if/when an update requires new variables to be added to `user_profile.cfg`.

The `_CLIENT_VARIABLE` macro in the `user_profile.cfg` file is used to customize the UI macros supplied by mainsail/fluidd.

printcfg is designed to work alongside those macros to enhance the experience.

More documentation will be added soon to give more detailed explanations of each of the many config options.

Stay tuned!

## Using the suite

The most important step to using this suite comes from the necessary additions in your slicer.

These commands will pass values from the slicer which the macros can then use to define the behavior.

This collects data such as the preheat temperatures, filament type/color, tool changes, filament changes, and layer counts.

The Start gcode is the most important part.

Start Gcode: (SuperSlicer)

    ;print_cfg variables
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=extruder_temp VALUE={first_layer_temperature[initial_extruder] + extruder_temperature_offset[initial_extruder]}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=bed_temp VALUE={first_layer_bed_temperature[initial_extruder]}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=chamber_temp VALUE={chamber_temperature}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_type VALUE="'{filament_type[initial_extruder]}'"
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_color VALUE={filament_colour_int}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=layer_count VALUE={total_layer_count}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=tool_count VALUE={total_toolchanges}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=tool_name VALUE="'{tool_name[initial_extruder]}'"
    start_print

End Gcode: (SuperSlicer)

    end_print

Before Layer Change: (SuperSlicer)

    ;print_cfg variables
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_type VALUE="'{filament_type[initial_extruder]}'"
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_color VALUE={filament_colour_int}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=layer_count VALUE={total_layer_count}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=layer_num VALUE={layer_num}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=layer_z VALUE={layer_z}

After Layer Change: (SuperSlicer)

    ;print_cfg variables
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_type VALUE="'{filament_type[initial_extruder]}'"
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_color VALUE={filament_colour_int}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=layer_count VALUE={total_layer_count}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=layer_num VALUE={layer_num}
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=layer_z VALUE={layer_z}

    ; Increment layer in Klipper
    SET_PRINT_STATS_INFO TOTAL_LAYER={total_layer_count} CURRENT_LAYER={layer_num}
    _BEGIN_LAYER

Color Change: (SuperSlicer)

    ;print_cfg variables
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_type VALUE="'{filament_type[initial_extruder]}'"
    SET_GCODE_VARIABLE MACRO=_printcfg VARIABLE=material_color VALUE={filament_colour_int}

    ; ESTIMATOR_ADD_TIME 240 Filament Change
    COLOR_CHANGE

As you can see, we use `SET_GCODE_VARIABLE` command extensively.

This allows all the macros in the suite to be kept apprised of any slicer values we may want to access.

It's completely ok if you don't use these settings in your klipper install or even in your slicer!

This suite is built to support ***everything*** so that the user can simply set the configuration values (either manually in the config file or via `SET_GCODE_VARIABLE` commands)

The idea is that you don't need to worry about the correct way to configure the slicer for your needs or even finding (or creating!) the right macros for your needs.

Everything is provided and you simply configure them to fit your requirements. No coding skills required :)

I promise this will be better documented in the future!