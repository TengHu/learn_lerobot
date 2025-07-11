#!/bin/bash
set -e

# Start SSH as root
service ssh start

# Switch to kasm-user and exec the original entrypoint
exec su kasm-user -c "$@" 