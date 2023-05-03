#!/bin/bash

## SSH key
ssh_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnC2fVeR8eoJ7U6pWyweIuWLSr5+moVWXk6Y93ALvvj nagisa@cutefemboy.com"

## SSH keys, user
mkdir ~/.ssh
echo $ssh_key > ~/.ssh/authorized_keys

## Permissions for user directory
chmod -v 700 ~
chmod -v 700 ~/.ssh
chmod -v 600 ~/.ssh/authorized_keys

# Check for sudo
if [ "$EUID" -eq 0 ]
then
    ## SSH keys, root
    mkdir ~/.ssh
    echo $ssh_key > ~/.ssh/authorized_keys

    ## Permissions for root directory
    chmod -v 700 ~
    chmod -v 700 ~/.ssh
    chmod -v 600 ~/.ssh/authorized_keys


    ## Hostname
    hostname mwasa-t2g2
    hostnamectl set-hostname mwasa-t2g2
    echo "mwasa-t2g2" >> /etc/hostname

    ## Packages


    # SSH
    cp sshd_config /etc/ssh/sshd_config
    systemctl start sshd
    systemctl enable sshd
    systemctl restart sshd

    ## Do dist upgrade :)
    do-release-upgrade
else
    sudo sh ./run.sh
fi
