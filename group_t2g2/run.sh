#!/bin/bash

ssh_key_mwasa="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXNCJs7SDSTfE0KeiB7Zo5rgNUg0qBLzKLtmvJK+0Xq1c3kfKmzCRcLUSHrPnOHMKIbzwqkDXXsEYmi6s+KJSFXJ0iqZP9bxOOcgId5EJC/SlAcjWo5H5tponeeNjqByexR2zkIjgFlIC/dcxSlV7KBfig4orv1c37euu4wg0ryq05sz8sWw2Hcy07mE262A6feaQdVjxOeNb2MoS7dPJjVTQ6HUcbOLMc6+gyjRitOOoshFndPTfTKobEVsWj5BvbxNRfDst4yC5WtENtYVKC9Jjg9PmbV9YzMZ7hpCArNEwQxoHeiW9tFMSMKrbyviXIx9fMBQ7cDpbQBx7IyCqsEWZztHinsIZ9tVmK54Ow1SghVZ4Ovx3aKyvTVgmLsGZk8wCNkBZ/ZT6RnAPlLutBtJfEmmBJOyQenITLa1hhd9bbHZ7HSMu60+hNTwt3UVepN1bnJtx1UNWvTCmCoyrI0ItTwwFm+gY8O4LllqiC3lhki4vuYJgcpPKwvY716x0= hero@nagisa"
ssh_key_s215771="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNujG8VyPPcLBEq3mwZF53/nGd/lRrMMAAtMsK3l8xWpFfhu2zoyq6eIQ9QJx6Dxr0qRe2+vk9LfG41IPibYpJ4ZPwnnZH/zZ6kejWYVx2t53HNVsCai3lVMrvFhpoJF53nQg/qbTvkga+OOdZeom18wsgNMywbWblhaGZzSZX4GSpF8D6wWb2oyrCZdZ51nBEW0Wu6JuUNtOgdlwNWxSiPFbWxBlEdiMW/xNwi45Z6hbiO8Bo4LvRK8y545uknmZ2jaj67jkH/gmahLTOmA+1gwKVqYaai0AmQVgbZYbcxj8/GyX2QH7jmYmaP1y/SSOmrsLmXUnFMnApTIb7KyRjoDEzmx5w+dkHyiqzx+jDCpvUbZdIF8bFrGPf1wXVH3hmzZvGFaZyMJlJw9oXb5WZ8KNRF9CLSFXxjp+vF+b+A38URet/SBLHXPnZNbGyN1TmMfCdiWj9aEpZ5yb67UBL2aZgnsOs1/nzwMuW91enRJCA3zurbOqzF5euFIJJuBRzWOZsgaf3o5JWdw24PVNffiB9rYMnS4PIBlL0DN6wsbbj9/WWb/g7iMAmb6Lb3jygXrE1B+J2i5Vou5PsA/GA+tzsRS9qhzY4Wdi8nJm/1nNv/i/sRuAUIQA6ozo9T0eBsLMllZWcPhfhJj3P0f5st13QNH6NVRgs2G8vvVrpyw== madsnielsen96@gmail.com"

# SSH keys, user
mkdir ~/.ssh
echo -e "$ssh_key_mwasa\n$ssh_key_s215771" > ~/.ssh/authorized_keys

# Permissions for user directory
chmod -v 700 ~
chmod -v 700 ~/.ssh
chmod -v 600 ~/.ssh/authorized_keys

# Check for sudo
if [ "$EUID" -eq 0 ]
then
    # SSH keys, root
    mkdir ~/.ssh
    echo -e "$ssh_key_mwasa\n$ssh_key_s215771" > ~/.ssh/authorized_keys

    # Permissions for root directory
    chmod -v 700 ~
    chmod -v 700 ~/.ssh
    chmod -v 600 ~/.ssh/authorized_keys

    # Hostname
    hostname server14
    hostnamectl set-hostname server14
    echo "server14.omicron.eitlab.diplom.dtu.dk" > /etc/hostname

    # Packages
    zypper rm SuSEfirewall2
    zypper in psmisc mlocate make man man-pages gcc-c++ patch
    zypper in dhcp-server iptables neovim logwatch docker

    # Stop wicked
    systemctl stop wicked
    systemctl disable wicked

    # SSH
    cp sshd_config /etc/ssh/sshd_config
    systemctl start sshd
    systemctl enable sshd

    # Network

    ## Network and firewall scripts
    cp network.sh /root/bin/network.sh
    cp reset.fw /root/bin/reset.fw
    cp shitty_firewall /root/bin/shitty_firewall

    chmod +x /root/bin/network.sh
    chmod +x /root/bin/reset.fw
    chmod +x /root/bin/shitty_firewall

    ## Network config
    cp network_config /etc/sysconfig/network/config
    netconfig update -f
#    cp resolv.conf /etc/resolv.conf

    ## Run network service
    cp network.service /etc/systemd/system/network.service
    systemctl start network.service
    systemctl enable network.service

    ## Run DHCP service
    cp dhcpd /etc/sysconfig/dhcpd
    cp dhcpd.conf /etc/dhcpd.conf
    systemctl start dhcpd.service
    systemctl enable dhcpd.service

    # Squid
#    docker-compose -f ./containers/squid/docker-compose.yml up -d
    sh ./containers/squid/run.sh

    # Enable firewall rules
    /root/bin/shitty_firewall

    # Shared folder for logs with a file for each group member
    ## Create shared group
    groupadd server_admins
    ## Create the users
    groupadd mwasa
    useradd -m --gid mwasa --groups server_admins mwasa
    groupadd s215771
    useradd -m --gid s215771 --groups server_admins s215771
    ## Add SSH-keys to the users, so they can log in
    mkdir /home/mwasa/.ssh
    echo $ssh_key_mwasa > /home/mwasa/.ssh/authorized_keys
    mkdir /home/s215771/.ssh
    echo $ssh_key_s215771 > /home/s215771/.ssh/authorized_keys
    ### Change permissions for the users' ssh directories
    chown -v -R mwasa /home/mwasa/.ssh
    chmod -v 700 /home/mwasa/.ssh
    chmod -v 600 /home/mwasa/.ssh/authorized_keys
    chown -v -R s215771 /home/s215771/.ssh
    chmod -v 700 /home/s215771/.ssh
    chmod -v 600 /home/s215771/.ssh/authorized_keys
    ## Create shared common directory for logging
    mkdir /var/log/adminlog
    chgrp -v -R server_admins /var/log/adminlog
    ### Remember setgid bit (2) to give group ownership to all new files
    chmod -v -R 2770 /var/log/adminlog
    ## Create files for logging
    touch /var/log/adminlog/mwasa.log
    touch /var/log/adminlog/s215771.log
    ## Change permissions for files to allow read by group and write by owner
    chown -v mwasa /var/log/adminlog/mwasa.log
    chown -v s215771 /var/log/adminlog/s215771.log
    ### 740 = owner everything, group read, everyone else nothing
    chmod -v 740 /var/log/adminlog/mwasa.log
    chmod -v 740 /var/log/adminlog/s215771.log

    # Monitoring and logging

    ## Logwatch
    mkdir /var/cache/logwatch
    echo "MailTo = mwasa@dtu.dk, s215771@student.dtu.dk" >> /etc/logwatch/conf/logwatch.conf
#    logwatch --detail Low --range today

    ## Tripwire
    tar -xvf tripwire-2.4.2.2-src.tar.bz2
    mv tripwire-2.4.2.2-gcc-4.7.patch tripwire-2.4.2.2/
    cd tripwire-2.4.2.2/
    patch -p1  < tripwire-2.4.2.2-gcc-4.7.patch
    ./configure --sysconfdir=/etc/tripwire
    make
    make install
    cd ../
    /etc/tripwire --init
    /usr/local/sbin/tripwire --init
    cp twpol.txt /etc/tripwire/twpol.txt 
    /usr/local/sbin/twadmin --create-polfile /etc/tripwire/twpol.txt
    /usr/local/sbin/tripwire --init

    reboot
else
    sudo sh ./run.sh
fi