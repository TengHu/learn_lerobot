#!/bin/bash
set -e

# Run user_startup.sh as root
/dockerstartup/user_startup.sh

# Now switch to user 1000 and run the next script(s)
exec gosu 1000 "$@" 