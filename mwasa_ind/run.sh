#!/bin/bash

## SSH keys, user
mkdir ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnC2fVeR8eoJ7U6pWyweIuWLSr5+moVWXk6Y93ALvvj nagisa@cutefemboy.com" >> ~/.ssh/authorized_keys

## Permissions for user directory
chmod -v 700 ~
chmod -v 700 ~/.ssh
chmod -v 600 ~/.ssh/authorized_keys

## SSH keys, root
sudo mkdir ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnC2fVeR8eoJ7U6pWyweIuWLSr5+moVWXk6Y93ALvvj nagisa@cutefemboy.com" | sudo tee -a  ~/.ssh/authorized_keys

## Permissions for root directory
sudo chmod -v 700 ~
sudo chmod -v 700 ~/.ssh
sudo chmod -v 600 ~/.ssh/authorized_keys


## Hostname
sudo hostname mwasa-t2g2
sudo hostnamectl set-hostname mwasa-t2g2
echo "mwasa-t2g2" | sudo tee -a /etc/hostname

## Packages


# SSH
sudo cp sshd_config /etc/ssh/sshd_config
sudo systemctl start sshd
sudo systemctl enable sshd
sudo systemctl restart sshd

## Do dist upgrade :)
sudo do-release-upgrade
