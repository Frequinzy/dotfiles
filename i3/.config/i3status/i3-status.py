#!/usr/bin/python3

import sys
import subprocess
import json

def get_brightness():
    current = float(subprocess.run(["brightnessctl", "g"],
       stdout=subprocess.PIPE, text=True).stdout.strip())
    max_val = float(subprocess.run(["brightnessctl", "m"],
           stdout=subprocess.PIPE, text=True).stdout.strip())
    percentage = current / max_val * 100
    icon = "🔆" if percentage > 50 else "🔅"
    return(icon + str(percentage) + "%")

def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()

if __name__ == '__main__':
    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)
        # insert information into the start of the json, but could be anywhere
        # CHANGE THIS LINE TO INSERT SOMETHING ELSE
        j.insert(0, {'full_text' : '%s' % get_brightness(), 'name' : 'gov'})
        # and echo back new encoded json
        print_line(prefix+json.dumps(j))
