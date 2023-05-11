#!/bin/bash

# SSH keys
ssh_key_laptop="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnC2fVeR8eoJ7U6pWyweIuWLSr5+moVWXk6Y93ALvvj nagisa@cutefemboy.com"
ssh_key_desktop="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFB/OxGoBrNAtxcGI6XFrGWMr+8Wv53x2oTx6EzDBh7 hero@cutefemboy.com"

# SSH
echo "[SSH Keys] Setting up SSH keys for the current user..."

## SSH keys
mkdir ~/.ssh
echo -e "$ssh_key_laptop\n$ssh_key_desktop" > ~/.ssh/authorized_keys

## Permissions for directory
chmod -v 700 ~
chmod -v 700 ~/.ssh
chmod -v 600 ~/.ssh/authorized_keys

echo "[SSH Keys] Done!"

# Check for git folder
echo "[Git] Checking for git..."
if [ -d ".git" ]
then
    echo "[Git] Git repository found. Checking for updates..."
    # Check if updated
    ## Checkout to master and fetch
    git checkout master
    git fetch
    ## Get head and upstream hash
    HASH_HEAD=$(git rev-parse HEAD)
    HASH_UPSTREAM=$(git rev-parse master@{upstream})
    ## Compare hashes
    if [ "$HASH_HEAD" != "$HASH_UPSTREAM" ]
    then
        ## If hashes don't match, pull and try again
        echo "Hashes doesn't match, pulling and trying again!"
        git pull
        sh ./run.sh
        exit 0
    else
        echo "Hashes match, running configration..."
        # Check for sudo
        echo "Checking for sudo..."
        if [ "$EUID" -eq 0 ]
        then
            echo "Running as root, continuing..."

            # Hostname
            echo "Setting hostname..."
            hostname mwasa-t2g2
            hostnamectl set-hostname mwasa-t2g2
            echo "mwasa-t2g2" >> /etc/hostname
            
            # SSH
            echo "Starting SSH server..."
            cp sshd_config /etc/ssh/sshd_config
            systemctl start sshd
            systemctl enable sshd
            systemctl restart sshd

            # Firewall Configuration
            echo "Configuring firewall..."
            sh ./firewall.sh

            # Enable proxy
            echo "Enabling proxy..."
            echo -e "http_proxy=http://192.168.154.1:3128\nhttps_proxy=https://192.168.154.1:3128" >> /etc/environment

            # Packages
            echo "[Packages] Updating and installing packages..."

            ## Update package index and upgrade packages
            apt-get update
            apt-get upgrade

            ## Install packages

            ### Install Snap (for LXD)
            apt-get install snapd

            ### Docker - https://docs.docker.com/engine/install/ubuntu/
            #### Uninstall old versions
            apt-get remove docker docker-engine docker.io containerd runc
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
            apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            #### Add a macvlan network - https://docs.docker.com/network/macvlan/
            echo "Creating macvlan network for Docker..."
            docker network create -d macvlan --subnet=192.168.154.0/24 --gateway=192.168.154.1 -o parent=eth0 server14net

            ### LXD - https://ubuntu.com/lxd and https://linuxcontainers.org/lxd/docs/master/
            #### Install LXD
            snap install lxd
            #### Init LXD
            lxd init --minimal
            #### Add a ipvlan network - https://linuxcontainers.org/lxd/docs/master/reference/devices_nic/
            echo "Creating ipvlan for LXD..."
            lxc profile create ipvlan
            lxc profile device add ipvlan eth0 nic nictype=ipvlan parent=eth0 mode=l2 ipv4.gateway=192.168.154.1 ipv4.address=192.168.154.0/24

            # Services
            echo "[Services] Starting services..."

            ## Minecraft
            echo "[Services] Starting Minecraft..."
            docker-compose -f ./services/minecraft/docker-compose.yml up -d
            ## API
            echo "[Services] Starting the Nuclear API..."
            docker-compose -f ./services/api/docker-compose.yml up -d
            ## Nginx
            echo "[Services] Starting the NGINX Server..."
            sh ./services/nginx/lxd_nginx.sh
        else
            echo "The script now needs to run with elevated permissions to continue, please elevate..."
            sudo sh ./run.sh
        fi
    fi
else
    # Set up git and pull the repo

    echo "Checking for and installing git..."
    sudo apt-get install git

    ## Deploy keys
    echo "Checking for deploy key configuration..."
    if [ -f ~/.ssh/config ] && grep -q "Host github.com-serverconfig" ~/.ssh/config
    then
        echo "Configuration found, proceeeding!"
    else
        echo "Configuration not found, creating new..."
        
        ## Generate key
        ssh-keygen -f ~/.ssh/id_rsa_deploy -t ed25519 -N '' -q
        echo "Please add the following SSH key to the deployment section on the repo: "
        cat ~/.ssh/id_rsa_deploy.pub
        read -p "Press Enter to continue" void

        ## Add deploy to SSH config
        printf "%s\n" "Host github.com-serverconfig" "  Hostname github.com" "  IdentityFile=~/.ssh/id_rsa_deploy" >> ~/.ssh/config
        chmod -v 600 ~/.ssh/config
    fi
    
    ## Clone repo
    echo "Cloning repo..."
    git clone git@github.com-serverconfig:DTUSoftware/LinuxServer.git

    # Run that file instead
    echo "Running newly downloaded file..."
    sh ./LinuxServer/mwasa_ind/run.sh
    exit 0
fi
