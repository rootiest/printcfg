# PrintCFG Klipper Suite

This set of macros is a full suite of features for Klipper.

It requires a fair bit of configuration, but everything can be configured by setting the values of variables in the [print_variables.cfg](print_variables.cfg) file.

You can also change any of these settings at runtime using `SET_GCODE_VARIABLE` commands.

These `SET_GCODE_VARIABLE` commands are also used to pass values from the slicer instead of the traditional method using parameters.

## Installation

To install the suite, run the following command:

    Command to be added shortly

This command will clone the repo into your config in a folder named `printcfg`.

The following line will be added to your `printer.cfg` file:

    [include printcfg/print_config.cfg]

This tells Klipper to include that file. The other files will be included from there.

The following line will be added to your `moonraker.conf` file:

    [include printcfg/moonraker-printcfg.conf]

This adds some moonraker configs, mainly the update_manager for printcfg updates.

## Configuration

The vast majority of the configuration is done via the `_printcfg` macro in `print_variables.cfg`.

The `_CLIENT_VARIABLE` macro in that same file is used to customize the default mainsail macros (which printcfg is designed to work with)

Additionally, there are some configurations you should be aware of `print_config.cfg`

That file contains various configuration sections the suite depends on, as well as optional includes that can be used to add additional functionality.

The necessary filament sensor configurations are also included there, as well as an `_extract_filament` macro that is used to perform filament unloads.

The suite is designed to be fully customizable without modifying any macros in the `print_macros.cfg` file.

For this reason, `_extract_filament` is kept in `print_config.cfg` to allow for easy customization if you have special needs for the unload procedure.

More documentation will be added to give more detailed explanations of each of the many config options.

Stay tuned!

## Using the suite

The most important step to using this suite comes from the necessary additions in your slicer.

The Start gcode is the most important part: (SuperSlicer)

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

