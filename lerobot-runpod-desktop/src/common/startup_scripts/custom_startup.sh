#!/bin/bash
set -e

# Now switch to root user
if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

/dockerstartup/user_startup.sh 

install_conda_and_lerobot() {
    export DISPLAY=:1

    # Install conda
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm ~/miniconda3/miniconda.sh

    # Initialize conda
    source ~/miniconda3/etc/profile.d/conda.sh
    source ~/miniconda3/bin/activate
    conda init --all

    # Install aerobat (lerobot)
    mkdir -p $HOME/Workspace
    cd $HOME/Workspace
    git clone https://github.com/huggingface/lerobot.git
}

# Switch to user 1000, install conda and lerobot, then sleep
su - 1000 -c '
    $(declare -f install_conda_and_lerobot)
    install_conda_and_lerobot
    sleep infinity
'
