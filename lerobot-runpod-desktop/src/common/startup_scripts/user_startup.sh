#!/bin/bash
set -e

start_ssh() {
    # Start SSH service
    if command -v service &> /dev/null; then
        service ssh start || true
    elif command -v systemctl &> /dev/null; then
        systemctl start ssh || true
    else
        /etc/init.d/ssh start || true
    fi
    echo "SSH service started."
}

start_jupyter() {
    JUPYTER_TOKEN=""
    if [[ -n "$JUPYTER_PASSWORD" ]]; then
        JUPYTER_TOKEN="--ServerApp.token=$JUPYTER_PASSWORD"
    else
        JUPYTER_TOKEN="--ServerApp.token=''"
    fi
    nohup jupyter lab --allow-root --no-browser --port=8888 --ip=0.0.0.0 $JUPYTER_TOKEN --ServerApp.allow_origin='*' &> $HOME/jupyter.log &
    echo "Jupyter Lab started on port 8888."
}

# Main
start_ssh
# start_jupyter


# Keep script running
sleep infinity 