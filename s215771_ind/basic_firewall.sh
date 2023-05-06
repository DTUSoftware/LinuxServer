#!/bin/bash

# Flush existing rules
iptables -F
ip6tables -F

# Set default policy to drop
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS input and output traffic
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 80,443 -m state --state ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
ip6tables -A OUTPUT -p tcp -m multiport --sports 80,443 -m state --state ESTABLISHED -j ACCEPT

# Allow DNS
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
ip6tables -A INPUT -p udp --dport 53 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 53 -j ACCEPT

# Disallow ping
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
ip6tables -A INPUT -p icmpv6 --icmpv6-type echo-request -j DROP

# Drop all other traffic
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP
ip6tables -A INPUT -j DROP
ip6tables -A FORWARD -j DROP
