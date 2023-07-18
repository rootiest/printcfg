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
##      Version 4.1.0 2023-7-3     ##
#####################################
-->

# PrintCFG Klipper Suite

[![GitHub Super-Linter](https://github.com/rootiest/printcfg/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

![header](docs/pretty_header.png)

This set of macros is a full suite of features for Klipper.

It is designed to be fully customizable to fit any printer or configuration. All without having to edit or understand the macros themselves. All configuration for the macros is done in the [user_profile.cfg](profiles/default/variables.cfg) file.

## Documentation

### [Documentation is available in the Wiki](https://github.com/rootiest/printcfg/wiki)

## Features

- Start/End Gcode Macros
- Smart Homing, no matter your hardware or configuration
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
- Smart Heat Soak: Non-blocking outside of print, blocking during print
- Filter usage tracking and reminders
- and more!

All of this can be configured and used with absolutely no knowledge of creating macros. Simply set configuration values like you do for other klipper configurations and the macros will automatically adjust to your settings.

## New Features in 5.0.0

### NOTE: This is a major update still in development

- **Major code changes!** The code has been completely restructured to function as a Python Klipper Host extension. This means that the macros are now loaded as a Python module and can be used in any Klipper configuration. This opens up a huge number of new possibilities for the macros and allows them to be used in ways that were not possible before. Updating from previous versions will be seamless but may require some changes to your configuration.
- **New Configuration System!** The configuration system has been completely reworked to be more flexible and easier to use. The new system will use standard Klipper configuration files and will be much easier to understand and use. If you have configured anything in Klipper before, you will be able to configure these macros.
- **New Functionalities!** The macros have been reworked to be more flexible and easier to use. Many new features have been added and many existing features have been improved. The macros are now more customizable than ever before and introduce new functionality that is not possible with traditional Klipper macros.
- **New Compatibility!** The macros are now compatible with any Klipper configuration. Extra care has been taken to allow them to be used seamlessly with your own macros and configurations. The macros will not interfere with any existing macros or configurations. Gone are the hours of troubleshooting and debugging to get your own personal macros to work with a pre-made set of macros. PrintCFG will work with any configuration and any macros. Print your own way.
- **New Custom Features!** All PrintCFG variables are now accessible via the printer object. Slicer variables are also accessible via the printer object. This means that you can now create your own custom `START_PRINT` and `END_PRINT` macros that use PrintCFG and slicer variables. You can also create your own custom macros for any purpose you can imagine. The possibilities are endless.
- **True Flexibility!** Use as much or as little of PrintCFG as you want. You can use the entire suite of macros or just a few. You can use none of the macros and just use the variable system. You can use the macros as-is or customize them to your heart's content. You can even use the macros as a base for your own macros. The macros are designed to be as flexible as possible and to allow you to use them in any way you want.
- **New Documentation!** The documentation has been completely reworked to be more comprehensive and easier to understand. The documentation is now available in the [Wiki](https://github.com/rootiest/printcfg/wiki) and is much easier to navigate and use.
- **New Support!** The macros now have a dedicated Discord server for support and discussion. Join the [Rootiest Discord server](http://rootiest.com/discord.html) for information and one-on-one support for PrintCFG and my other projects.

## Contact

Rootiest on Discord (Voron and Klipper servers)

Donate to support my work:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/rootiest)

Join the [Rootiest Discord server](http://rootiest.com/discord.html) for information and support for my projects.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/rootiest/zippy_guides/main/resources/github-snake-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/rootiest/zippy_guides/main/resources/github-snake.svg">
  <img alt="Shows a snake consuming the squares from the rootiest contributions graph." src="https://raw.githubusercontent.com/rootiest/zippy_guides/main/resources/github-snake.svg">
</picture>
