import readline
import rlcompleter
import atexit
import os

# runtime libraries
import math

# tab completion
readline.parse_and_bind('tab: complete')

# history file
histfile = os.path.join(os.environ['XDG_CACHE_HOME'], 'python', 'history')

try:
    readline.read_history_file(histfile)
except IOError:
    pass

atexit.register(readline.write_history_file, histfile)

del os, histfile, readline, rlcompleter
