# IPTABLES CONFIGRATION FOR MWASA_IND
# LINUX SERVER AND NETWORK

# Clear the iptables
iptables -F
iptables -t nat -F
iptables -X

# Block everything by default
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Deny pinging
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Allow ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# Allow DNS
iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --sport 53 -j ACCEPT

# Allow webtraffic
iptables -A INPUT -p tcp --sport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Block everything else
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j DROP
