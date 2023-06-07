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

"""Module providingFunction LogFileHandler."""
import sys
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class LogFileHandler(FileSystemEventHandler):
    def __init__(self, watched_file, output_file):
        self.watched_file = watched_file
        self.output_file = output_file
        self.previous_line = None

    def on_modified(self, event):
        """When the file is modified, write the log lines to the output file."""
        if event.src_path == self.watched_file:
            try:
                with open(self.watched_file, 'r', encoding="utf-8") as f:
                    current_line = f.readline().strip()
                    log_index = current_line.find("log = ")
                    if log_index != -1:
                        log_text = current_line[log_index + len("log = "):]
                        if log_text != self.previous_line:
                            with open(self.output_file, 'a', encoding="utf-8") as output:
                                output.write(log_text + '\n')
                            self.previous_line = log_text
            except IOError as e:
                print("IOError: " + e.strerror)

# Example usage:
w_file = 'variables.cfg'
o_file = 'printcfg.log'

# Check for arguments:
if len(sys.argv) > 1:
    if sys.argv[1] == '-h' or sys.argv[1] == '--help':
        print('Usage: python3 log_logger.py <input_file> <o_file>')
        sys.exit(0)
    else:
        if len(sys.argv) > 2:
            w_file = sys.argv[1]
            o_file = sys.argv[2]
            


event_handler = LogFileHandler(w_file, o_file)
observer = Observer()
observer.schedule(event_handler, path='.', recursive=False)
observer.start()

try:
    while True:
        pass
except KeyboardInterrupt:
    observer.stop()

observer.join()
