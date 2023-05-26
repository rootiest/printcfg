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
##      Version 4.0.0 2023-5-26    ##
#####################################
-->

# PrintCFG Klipper Suite

- [PrintCFG Klipper Suite](#printcfg-klipper-suite)
  - [!!! WARNING: THIS IS STILL A WORK IN PROGRESS !!!](#-warning-this-is-still-a-work-in-progress-)
  - [Overview](#overview)
  - [Installation](#installation)
    - [What the install script does](#what-the-install-script-does)
  - [Configuration](#configuration)
  - [Using the suite](#using-the-suite)
  - [Profile Configuration](#profile-configuration)
    - [Versioning](#versioning)
    - [Default temperatures](#default-temperatures)
    - [Default Offset](#default-offset)
  - [Chamber Variables](#chamber-variables)
    - [Soaking Variables](#soaking-variables)
    - [Bed Fan Variables](#bed-fan-variables)
    - [Idle Time Variables](#idle-time-variables)
    - [Idle Action Variables](#idle-action-variables)
    - [Parking Variables](#parking-variables)
    - [Preheat Parking Variables](#preheat-parking-variables)
    - [Maintenance Parking Variables](#maintenance-parking-variables)
    - [Homing Variables](#homing-variables)
    - [Homing Macros](#homing-macros)
    - [Pause Macros](#pause-macros)
    - [Speed Variables](#speed-variables)
    - [Filter Variables](#filter-variables)
    - [Controller Fan Variables](#controller-fan-variables)
    - [Exhaust Fan Variables](#exhaust-fan-variables)
    - [Docking Probe Variables](#docking-probe-variables)
    - [Z Calibration Variables](#z-calibration-variables)
    - [Meshing Variables](#meshing-variables)
    - [Nozzle Cleaning Variables](#nozzle-cleaning-variables)
    - [Purging Variables](#purging-variables)
    - [End Gcode Variables](#end-gcode-variables)
    - [Filament Change Variables](#filament-change-variables)
    - [Status Output Variables](#status-output-variables)
    - [LED Status Variables](#led-status-variables)
    - [Audio Status Variables](#audio-status-variables)
    - [Telegram Status Variables](#telegram-status-variables)
    - [DO NOT EDIT BELOW](#do-not-edit-below)
  - [Client Macro Variables](#client-macro-variables)
  - [Submitting A Profile](#submitting-a-profile)

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

    curl https://raw.githubusercontent.com/rootiest/printcfg/master/scripts/install.sh | bash -s -- default

### What the install script does

The install script will begin by checking for dependencies and installing them if they are missing.

It will then clone the repo into your home directory in a folder named `printcfg`. 

Please do not modify the contents of this folder.

The files for the profile you specified will be copied into your main config folder alongside `printer.cfg`.

This will consist of two files: `user_profile.cfg` and `user_config.cfg`.

> NOTE: You are free to modify these files as you see fit, but please only modify files that begin with `user_` so that the update system can successfully merge changes. 
> 
> These files will be placed in your main config folder, so they will not be overwritten by future updates.

The following line will be added to your `printer.cfg` file:

    [include print_config.cfg]

This tells Klipper to include the printcfg config file. The other files will be included from there.

The following line will be added to your `moonraker.conf` file:

    [include printcfg/moonraker-printcfg.conf]

This adds some moonraker configuration, specifically the `update_manager` for printcfg updates.

After all of these changes are made and verified, the script will restart Klipper and Moonraker.

Future updates will be performed by the `update_manager` service and will typically require a restart of only Klipper.

Most updates will be performed automatically, but some may require manual intervention. The installer will notify you if this is the case.

When the update requires manual intervention, you will be notified of the changes that need to be made to your user_profile.cfg file and the installer will exit. Run the setup.sh script again to verify the changes were made and continue the update.

In most cases this will only require you to add new variables or remove obsolete variables from your user_profile.cfg file.

Best efforts will be made to avoid this as much as possible, but future features may require new variables to be added and the process has been made as simple as possible.

It's important to keep the user_profile.cfg file untouched by the automated update process so that your customizations are not overwritten.

When new features are added, you will likely prefer to customize them to your liking, so it's best not to automatically append potentially unwanted new variables to your profile config.

I'm also open to suggestions for improving this process or PRs that add an interactive update process for profile changes from a patch file.

## Configuration

The vast majority of the configuration is done via the `_printcfg` macro in `user_profile.cfg`.

This is the "master" macro that hosts the configuration variables for the entire suite. 

It is here that we configure the behavior of the suite.

Additional configuration may also be required via the `user_config.cfg` file.

This file is used for non-macro configuration sections that the suite requires. It also manages the inclusion of the other config files.

Please only modify files that begin with `user_` so that the update system can successfully merge changes.

You will be notified if/when an update requires new variables to be added to `user_profile.cfg`.

The `_CLIENT_VARIABLE` macro in the `user_profile.cfg` file is used to customize the UI macros supplied by mainsail/fluidd.

printcfg is designed to work alongside those macros to enhance the experience and provide a more seamless integration with typical klipper workflows.

Preset profiles are [available](./profiles/) for various common configurations.

If you would like to submit a profile, please see the [Submitting A Profile](#submitting-a-profile) section below.

 I'd love to have a wide variety of community profiles available for everyone to choose from!

Custom configuration can be achieved by editing the `user_profile.cfg` file on your local installation.

See the [Profile Configuration](#profile-configuration) section below for more information.

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

## Profile Configuration

The bulk of profile configuration occurs in the `user_profile.cfg` file. There are a large number of variables which can be adjusted to achieve your desired behavior:

### Versioning

- `variable_version` 
  - Determines when updates require new variables to be added to the profile. It is used by the install script to determine when profiles need updating.

### Default temperatures

- `variable_extruder_temp`
  - Sets the extruder preheat temperature. The value here will be treated as the default unless overridden by the slicer.
- `variable_extruder_pretemp`
  - Sets a pre-preheating temperature for the extruder. This is useful with TAP where the extruder should be heated partially to improve probing.
- `variable_bed_temp`
  - Sets the heater_bed preheat temperature. The value here will be treated as the default unless overridden by the slicer.

### Default Offset

- `variable_z_offset`
  - Sets the default z_offset. The value here will be applied as a gcode offset.

## Chamber Variables

- `variable_chamber_type`
    - Defines the chamber sensor type. This could be 'temperature_sensor', 'temperature_fan', 'heater', or 'none'
- `variable_chamber_name`
  - Defines the name of the chamber sensor. Typically this will be 'chamber'.
- `variable_chamber_temp`
  - Sets the default chamber temperature target used in heat soak procedures.
- `variable_chamber_time`
  - Sets the default chamber soak time used in heat soak procedures.

### Soaking Variables

- `variable_heat_soak`
  - Determines whether to heat soak during print start process.
- `variable_time_soak`
  - Determines whether to heat soak for a specified time (variable_chamber_time)
- `variable_temp_soak`
  - Determines whether to heat soak until the chamber reaches a specified temperature (variable_chamber_temp)

### Bed Fan Variables

- `variable_bed_fan`
  - Determines whether to control bed fans
- `variable_bed_fan_fast`
  - Sets the command to turn the bed fans on "fast" speed.
- `variable_bed_fan_slow`
  - Sets the command to turn the bed fans on "slow" speed.
- `variable_bed_fan_stop`
  - Sets the command to turn the bed fans off.

### Idle Time Variables

- `variable_idle_time`
  - Sets the default time used for idle_timeout.
- `variable_m600_idle_time`
  - Sets the time used for idle_timeout during filament changes.
- `variable_pause_idle_time`
  - Sets the time used for idle_timeout during pauses.
- `variable_soak_idle_time`
  - Sets the time used for idle_timeout during heat soaks.

### Idle Action Variables

- `variable_idle_extruder`
  - Determines whether the extruder is disabled during idle_timeout.
- `variable_idle_bed`
  - Determines whether the heater_bed is disabled during idle_timeout.
- `variable_idle_chamber`
  - Determines whether the chamber heater is disabled during idle_timeout.
- `variable_idle_steppers`
  - Determines whether the steppers are disabled during idle_timeout.
- `variable_idle_power`
  - Determines whether the printer power is toggled off during idle_timeout.

### Parking Variables

- `variable_park_x`
  - Sets the default x position for parking.
- `variable_park_y`
  - Sets the default y position for parking.
- `variable_park_z`
  - Sets the default z position for parking.
- `variable_park_zrel`
  - Sets the default z relative position for parking.
- `variable_park_zmin`
  - Sets the default z minimum position for parking.
- `variable_park_speed`
  - Sets the default speed for parking moves.
- `variable_park_extrude`
  - Sets the default extrusion amount for parking moves.
- `variable_park_base`
  - Sets the "native" command for parking. This is typically something like '_TOOLHEAD_PAUSE_PARK_CANCEL'

### Preheat Parking Variables

- `variable_preheat_x`
  - Sets the default x position for preheat parking.
- `variable_preheat_y`
  - Sets the default y position for preheat parking.
- `variable_preheat_z`
  - Sets the default z position for preheat parking.

### Maintenance Parking Variables

Setting any of these values to -1 will park at the center of all 3 axes.

- `variable_maint_x`
  - Sets the default x position for maintenance parking.
- `variable_maint_y`
  - Sets the default y position for maintenance parking.
- `variable_maint_z`
  - Sets the default z position for maintenance parking.

### Homing Variables

- `variable_home_x`
  - Sets the default x position for z-homing.
- `variable_home_y`
  - Sets the default y position for z-homing.
- `variable_pre_home_z`
  - Sets the z-hop to be performed before homing. NOTE: Enable force_move to use this feature
- `variable_post_home_z`
  - Sets the z-hop to be performed after homing.
- `variable_home_travel_speed`
  - Sets the default travel speed for homing moves.
- `variable_home_z_speed`
  - Sets the default z speed for homing moves.
- `variable_home_retract`
  - Sets the amount of "bounceback" after the endstop has been triggered.
- `variable_home_retract_speed`
  - Sets the speed of the "bounceback" after the endstop has been triggered.
- `variable_sensorless_home`
  - Determines whether to use sensorless homing.
- `variable_home_current`
  - Sets the stepper current to be used during homing.

### Homing Macros
- `variable_home_x_macro`
  - Sets the macro to be used for x-homing.
- `variable_home_y_macro`
  - Sets the macro to be used for y-homing.
- `variable_home_z_macro`
  - Sets the macro to be used for z-homing.

### Pause Macros
- `variable_pause_macro`
  - Sets the macro to be used for pausing.
- `variable_pause_no_park`
  - Sets the macro to be used for pausing without parking.

### Speed Variables
- `variable_default_speed_factor`
  - Sets the default speed factor for all moves.
- `variable_start_offset`
  - Determines whether to apply offset at start.
- `variable_end_offset`
  - Determines whether to remove offset at end.
- `variable_start_speed_factor`
  - Determines whether to apply speed factor at start.
- `variable_end_speed_factor`
  - Determines whether to remove speed factor at end.
- `variable_travel_speed`
  - Sets the default travel speed.

### Filter Variables

- `variable_nevermore`
  - Determines whether to use the Nevermore filter.
- `variable_nevermore_name`
  - Sets the name of the Nevermore filter.
- `variable_nevermore_type`
  - Sets the type of the Nevermore filter.
- `variable_nevermore_speed`
  - Sets the speed of the Nevermore filter.
- `variable_use_scrubber`
  - Determines whether to run the filter after a print completes.
- `variable_scrub_time`
  - Sets the default scrub time.
- `variable_scrub_speed`
  - Sets the default scrubbing fan speed.
- `variable_hours_until_replacement`
  - Sets the default number of hours until filter replacement notifications should be triggered.
- `variable_filter_replacement`
  - Sets the filter replacement notification command.

### Controller Fan Variables

- `variable_controller_fan`
  - Determines whether to control the controller fan.
- `variable_controller_fan_start`
  - Sets the command to turn the controller fan on.
- `variable_controller_fan_stop`
  - Sets the command to turn the controller fan off.

### Exhaust Fan Variables

- `variable_exhaust_fan`
  - Determines whether to control the exhaust fan.
- `variable_exhaust_fan_start`
  - Sets the command to turn the exhaust fan on.
- `variable_exhaust_fan_stop`
  - Sets the command to turn the exhaust fan off.
- `variable_exhaust_time`
  - Sets the default time to run the exhaust fan after a print completes.

### Docking Probe Variables

- `variable_docking_probe`
  - Determines whether to use the docking probe.
- `variable_attach_macro`
  - Sets the macro to be used for attaching the docking probe.
- `variable_dock_macro`
  - Sets the macro to be used for docking the docking probe.

### Z Calibration Variables

- `variable_z_tilt`
  - Determines whether to use z-tilt compensation.
- `variable_qgl`
  - Determines whether to use Quad Gantry Leveling.

### Meshing Variables

- `variable_bed_mesh`
  - Determines whether to use bed meshing.
- `variable_mesh_adaptive`
  - Determines whether to use adaptive meshing.
- `variable_load_mesh`
  - Determines whether to load the mesh at startup.
- `variable_mesh_profile`
  - Sets the default mesh profile.
- `variable_mesh_fuzz_enable`
  - Determines whether to enable fuzzing of the mesh.
- `variable_mesh_fuzz_min`
  - Sets the minimum amount in mm a probe point can be randomized, default is 0.
- `variable_mesh_fuzz_max`
  - Sets the maximum amount in mm a probe point can be randomized, default is 4.

### Nozzle Cleaning Variables

- `variable_cleaning`
  - Determines whether to use nozzle cleaning.
- `variable_clean_probe`
  - Determines whether to clean nozzle before probing.
- `variable_clean_end`
  - Determines whether to clean nozzle after printing.
- `variable_post_clean_home`
  - Determines whether to home after cleaning.
- `variable_clean_m600`
  - Determines whether to clean nozzle after filament change.
- `variable_clean_macro`
  - Sets the macro to be used for cleaning the nozzle.
- `variable_clean_x`
  - Sets the x start position for cleaning the nozzle.
- `variable_clean_y`
  - Sets the y start position for cleaning the nozzle.
- `variable_clean_z`
  - Sets the z start position for cleaning the nozzle.
- `variable_clean_wipe_axis`
  - Sets the axis to be used when cleaning the nozzle.
- `variable_clean_wipe_dist`
  - Sets the move distance to be used when cleaning the nozzle.
- `variable_clean_wipe_qty`
  - Sets the number of times to wipe the nozzle.
- `variable_clean_wipe_spd`
  - Sets the speed to be used when cleaning the nozzle.
- `variable_clean_raise_dist`
  - Sets the distance to raise the nozzle after cleaning.
- `variable_clean_temp`
  - Sets the minimum temperature to be used when cleaning the nozzle.
- `variable_clean_hot`
  - Determines whether to heat the nozzle before cleaning.

### Purging Variables

- `variable_purging`
  - Determines whether to purge the nozzle before print.
- `variable_purge_macro`
  - Sets the macro to be used for purging the nozzle.
- `variable_purge_adaptive`
  - Determines whether to use adaptive purging.
- `variable_purge_z_height`
  - Sets the z height to be used when purging.
- `variable_purge_tip_distance`
  - Sets the distance to move the nozzle away from the purge line.
- `variable_purge_amount`
  - Sets the amount of filament to purge.
- `variable_purge_flow_rate`
  - Sets the flow rate to be used when purging.
- `variable_purge_x`
  - Sets the default x start position for purging the nozzle.
- `variable_purge_y`
  - Sets the default y start position for purging the nozzle.
- `variable_purge_dist_x`
  - Sets the default x distance to move when purging the nozzle.
- `variable_purge_dist_y`
  - Sets the default y distance to move when purging the nozzle.
- `variable_purge_size`
  - Sets the default size of the purge line.
- `variable_purge_debug`
  - Enables debug logging for purging.

### End Gcode Variables
- `variable_end_print`
  - Determines whether to run the end print macro.
- `variable_end_retract`
  - Determines whether to retract filament at the end of a print.
- `variable_end_retract_length`
  - Sets the length of filament to retract at the end of a print.
- `variable_end_retract_speed`
  - Sets the speed to retract filament at the end of a print.
- `variable_power_off`
  - Determines whether to power off the printer at the end of a print.
- `variable_off_macro`
  - Sets the macro to be used for powering off the printer.
- `variable_end_unload`
  - Determines whether to unload filament at the end of a print.

### Filament Change Variables

- `variable_m600`
  - Sets the command to be used for filament change. 
- `variable_auto_filament_sensor`
  - Determines whether to automatically toggle the filament sensor.
- `variable_auto_filament_delay`
  - Sets the delay in seconds before toggling the filament sensor.
- `variable_filament_sensor`
  - Sets the name of the filament sensor.
- `variable_m600_default_temp`
  - Sets the default minimum temperature to be used when changing filament.
- `variable_m600_load_fast`
  - Sets the length to load the filament before reaching the hotend
- `variable_m600_load_slow`
  - Sets the length to extrude the filament after reaching the hotend
- `variable_m600_unload_length`
  - Sets the length to retract the filament during unload
- `variable_m600_purge_length`
  - Sets the length to extrude the filament during purging
- `variable_m600_fast_speed`
  - Sets the speed for fast extruder moves (before reaching the hotend)
- `variable_m600_med_speed`
  - Sets the speed for medium extruder moves (catching filament in gears)
- `variable_m600_slow_speed`
  - Sets the speed for slow extruder moves (after reaching the hotend)
- `variable_m600_unload_speed`
  - Sets the speed for retracting during unload after clearing the hotend
- `variable_auto_unload`
  - Determines whether to automatically unload filament after a runout is triggered.
- `variable_auto_load`
  - Determines whether to automatically load filament after changing.

### Status Output Variables

- `variable_output`
  - Set the output type for status messages. Can be 116, 117, or 118.
- `variable_error_output`
  - Set the output type for error messages. Can be 116, 117, or 118.

### LED Status Variables

- `variable_led_status`
  - Determines whether to use the LED status feature.
- `variable_status_ready`
  - Sets the LED macro for the ready status.
- `variable_status_busy`
  - Sets the LED macro for the busy status.
- `variable_status_preprint`
  - Sets the LED macro for the preprint status.
- `variable_status_homing`
  - Sets the LED macro for the homing status.
- `variable_status_cal_z`
  - Sets the LED macro for the z calibration status.
- `variable_status_mesh`
  - Sets the LED macro for the mesh leveling status.
- `variable_status_clean`
  - Sets the LED macro for the nozzle cleaning status.
- `variable_status_heat`
  - Sets the LED macro for the heating status.
- `variable_status_m600`
  - Sets the LED macro for the filament change status.
- `variable_status_load`
  - Sets the LED macro for the filament load status.
- `variable_status_unload`
  - Sets the LED macro for the filament unload status.
- `variable_status_part_ready`
  - Sets the LED macro for the part ready (print complete) status.
- `variable_status_error`
  - Sets the LED macro for the error status.
- `variable_status_printing`
  - Sets the LED macro for the printing status.

### Audio Status Variables

- `variable_audio_status`
  - Determines whether to use the audio status feature.
- `variable_start_audio`
  - Sets the audio macro for the start status.
- `variable_error_audio`
  - Sets the audio macro for the error status.
- `variable_success_audio`
  - Sets the audio macro for the success status.
- `variable_resume_audio`
  - Sets the audio macro for the resume status.
- `variable_m600_audio`
  - Sets the audio macro for the filament change status.
- `variable_alert_freq`
  - Sets the frequency for the alert tone.

### Telegram Status Variables

- `variable_use_telegram`
  - Determines whether to use the telegram status feature.
- `variable_telegram_runout`
  - Determines whether to send a telegram message when a runout is triggered.

### DO NOT EDIT BELOW

The rest of the variables in this macro are used internally and should not be edited.

## Client Macro Variables

These variables configure the mainsail/fluidd macros. See your preferred client documentation for more information.

## Submitting A Profile

- Spent a lot of time dialing in your profile and want to show it off?

- Have a profile for a popular printer that you think others would benefit from?

- Have a unique profile that you think others would enjoy?

If you would like to submit a profile, please create a pull request with your profile directory added to the `profiles` folder.

The profile name should be short and not contain any spaces or special characters. It should also be unique and not conflict with any existing profiles. The profile name should be all lowercase. Please also refrain from using any offensive or discriminatory language in your profile name or description.

Each profile must consist of the following files:

- **variables.cfg**

  This file contains the profile variables. It should be created from your `user_profile.cfg` file.

- **config.cfg**

  This file contains the profile configuration. It should be created from your `user_config.cfg` file.

- **patch_notes.txt**

  This file contains the patch notes for the profile. It should list the version of the profile and "initial release" if it is the first release.

- **README.md**
  
  This file contains the profile description. It should have one header with the profile name with By: Your Name underneath. It should also have a description of the profile and any special instructions for using it. You should also briefly list the printer and components the profile was designed for.

  If your README file requires any images, please place them in an `images` folder within your profile folder and reference them in your README file.

  Feel free to get creative with your README file, as long as it meets then requirements above and does so in a clear and concise manner at the top of the file.

  The main goal is to make it easy for users to quickly find the information they need to use your profile.

  Keep in mind that large files will increase the size of the install on every machine whether they use your profile or not. All profiles are synced alongside the rest of the repo. But only the selected profile is added to the user's config.
  
  Please be reasonable with the size of your images to keep the repository size small and the sync time low.

  When your profile is installed on a user's printer, only the variables.cfg and config.cfg files are used. The README.md and patch_notes.txt files are only used for display purposes in the repository. Similarly, any additional files you include in your profile will not be added to the user's config.