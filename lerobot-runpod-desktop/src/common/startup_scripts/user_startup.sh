#!/bin/bash
set -e

start_ssh() {
    # Add public key to authorized_keys if provided
    if [[ -n "$PUBLIC_KEY" ]]; then
        # For root
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
        echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys

        # For kasm-user
        mkdir -p /home/kasm-user/.ssh
        chmod 700 /home/kasm-user/.ssh
        echo "$PUBLIC_KEY" >> /home/kasm-user/.ssh/authorized_keys
        chmod 600 /home/kasm-user/.ssh/authorized_keys
        chown -R kasm-user:kasm-user /home/kasm-user/.ssh

        echo "Public key added to root and kasm-user authorized_keys."
    else
        echo "No PUBLIC_KEY provided, skipping SSH key setup."
    fi


    
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