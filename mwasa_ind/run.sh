#!/bin/bash

# SSH key
ssh_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnC2fVeR8eoJ7U6pWyweIuWLSr5+moVWXk6Y93ALvvj nagisa@cutefemboy.com"

# SSH keys, user
mkdir ~/.ssh
echo $ssh_key > ~/.ssh/authorized_keys

# Permissions for user directory
chmod -v 700 ~
chmod -v 700 ~/.ssh
chmod -v 600 ~/.ssh/authorized_keys

# Check for sudo
if [ "$EUID" -eq 0 ]
then
    # SSH keys, root
    mkdir ~/.ssh
    echo $ssh_key > ~/.ssh/authorized_keys

    # Permissions for root directory
    chmod -v 700 ~
    chmod -v 700 ~/.ssh
    chmod -v 600 ~/.ssh/authorized_keys

    # Hostname
    hostname mwasa-t2g2
    hostnamectl set-hostname mwasa-t2g2
    echo "mwasa-t2g2" >> /etc/hostname
    
    # SSH
    cp sshd_config /etc/ssh/sshd_config
    systemctl start sshd
    systemctl enable sshd
    systemctl restart sshd

    # Firewall Configuration

    sh ./firewall.sh

    # Enable proxy
    echo -e "http_proxy=http://192.168.154.1:3128\nhttps_proxy=https://192.168.154.1:3128" >> /etc/environment

    # Packages

    ## Update package index and upgrade packages
    apt-get update
    apt-get upgrade

    ## Install packages

    ### Docker - https://docs.docker.com/engine/install/ubuntu/
    #### Uninstall old versions
    sudo apt-get remove docker docker-engine docker.io containerd runc
    #### Install dependencies
    apt-get install ca-certificates curl gnupg
    #### Add the Docker repo's GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    #### Add the repository
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    #### Update apt package index, again
    apt-get update
    #### Finally, install Docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Do dist upgrade :)
    do-release-upgrade
else
    sudo sh ./run.sh
fi
