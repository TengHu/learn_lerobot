#!/bin/bash
set -e

# Now switch to root user
if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

/dockerstartup/user_startup.sh 

# Now switch to user 1000 and run the next script(s)
su -s /bin/bash -c "sleep infinity" 1000 
