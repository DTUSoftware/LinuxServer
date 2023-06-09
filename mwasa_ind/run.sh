#!/bin/bash

# SSH keys
ssh_key_laptop="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnC2fVeR8eoJ7U6pWyweIuWLSr5+moVWXk6Y93ALvvj nagisa@cutefemboy.com"
ssh_key_desktop="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFB/OxGoBrNAtxcGI6XFrGWMr+8Wv53x2oTx6EzDBh7 hero@cutefemboy.com"

# SSH
echo "[SSH Keys] Setting up SSH keys for the current user..."

## SSH keys
mkdir ~/.ssh
printf "%s\n" "$ssh_key_laptop" "$ssh_key_desktop" > ~/.ssh/authorized_keys

## Permissions for directory
chmod -v 700 ~
chmod -v 700 ~/.ssh
chmod -v 600 ~/.ssh/authorized_keys

echo "[SSH Keys] Done!"

# Check for git folder
echo "[Git] Checking for git..."
if [ -d "../.git" ]
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
        git reset --hard
        git pull
        sh ./run.sh
        exit 0
    else
        echo "Hashes match, running configration..."
        # Check for sudo
        echo "Checking for sudo..."
        if [ "$(id -u)" -eq "0" ]
        then
            echo "Running as root, continuing..."

            # Hostname
            echo "Setting hostname..."
            hostname mwasa-t2g2
            hostnamectl set-hostname mwasa-t2g2
            echo "mwasa-t2g2" > /etc/hostname
            if grep -q "mwasa-t2g2" /etc/hosts
            then
                echo "Hostname already in hosts..."
            else
                echo "Hostname not in hosts, adding..."
                echo "172.0.1.1 mwasa-t2g2" > /etc/hosts
            fi
            
            # SSH
            echo "Starting SSH server..."
            cp sshd_config /etc/ssh/sshd_config
            systemctl start ssh
            systemctl enable ssh
            systemctl restart ssh

            # DNS
            if grep -q "DNS=1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001" /etc/systemd/resolved.conf
            then
                echo "DNS already set!"
            else
                echo "Adding DNS!"
                echo "DNS=1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001" >> /etc/systemd/resolved.conf
            fi

            # Network interfaces
            ## Enable all interfaces
            ifconfig ens3 up
            ifconfig ens4 up

            ## Change netplan to enable DHCP on all interfaces
            cp ./01-netcfg.yaml /etc/netplan/01-netcfg.yaml
            sudo netplan apply

            # Firewall Configuration
            echo "Configuring firewall..."
            sh ./firewall.sh

            # Enable proxy
            echo "Enabling proxy..."
            if grep -q "http_proxy=http://192.168.154.1:3128" /etc/environment
            then
                echo "Proxy already set!"
            else
                echo "Adding to envionment!"
                printf "%s\n" "http_proxy=http://192.168.154.1:3128" "https_proxy=http://192.168.154.1:3128" >> /etc/environment
            fi

            # Packages
            echo "[Packages] Updating and installing packages..."

            ## Update package index and upgrade packages
            apt-get update -y
            apt-get upgrade -y

            ## Install packages

            ### Install Snap (for LXD)
            apt-get install snapd -y

            ### Docker - https://docs.docker.com/engine/install/ubuntu/
            #### Uninstall old versions
            apt-get remove docker docker-engine docker.io containerd runc -y
            #### Install dependencies
            apt-get install ca-certificates curl gnupg -y
            #### Add the Docker repo's GPG key
            if [ -f "/etc/apt/keyrings/docker.gpg" ]
            then
                echo "Docker GPG already installed, skipping..."
            else
                echo "Installing Docker's GPG key..."
                install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                chmod a+r /etc/apt/keyrings/docker.gpg
            fi
            #### Add the repository
            echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            #### Update apt package index, again
            apt-get update -y
            #### Finally, install Docker
            apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y
            #### Add a macvlan network - https://docs.docker.com/network/macvlan/
            #echo "Creating macvlan network for Docker..."
            # docker network create -d macvlan --subnet=192.168.154.0/28 --gateway=192.168.154.1 -o parent=ens4 server14net

            ### LXD - https://ubuntu.com/lxd and https://linuxcontainers.org/lxd/docs/master/
            #### Install LXD
            snap install lxd
            #### Init LXD
            lxd init --minimal
            #### Add a ipvlan network - https://linuxcontainers.org/lxd/docs/master/reference/devices_nic/
            #echo "Creating ipvlan for LXD..."
            #lxc profile create ipvlan
            #lxc profile device add ipvlan ens3 nic nictype=ipvlan parent=ens3 mode=l2 ipv4.gateway=192.168.154.1 ipv4.address=192.168.154.17/28
            #### Add a macvlan network
            lxc network create macvlan --type=macvlan parent=ens4

            # Restart Docker for firewall config
            echo "Restarting Docker..."
            service docker restart
            echo "Restarting LXD..."
            snap restart lxd

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
            current_dir="$PWD"
            cd ./services/nginx
            sh ./lxd_nginx.sh
            cd "$PWD"
        else
            echo "The script now needs to run with elevated permissions to continue, please elevate..."
            sudo sh ./run.sh
            exit 0
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
    cd ./LinuxServer
    git config --global --add safe.directory $PWD
    cd ./mwasa_ind
    sh ./run.sh
    exit 0
fi
