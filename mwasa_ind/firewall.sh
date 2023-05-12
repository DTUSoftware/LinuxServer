# IPTABLES CONFIGRATION FOR MWASA_IND
# LINUX SERVER AND NETWORK

# Function to add rule to both iptables and ip6tables
iptablesBoth()
{
    iptables "$@"
    ip6tables "$@"
}

# Clear the iptables
iptablesBoth -F
iptablesBoth -t nat -F
iptablesBoth -X

# Block everything by default
iptablesBoth -P INPUT DROP
iptablesBoth -P FORWARD DROP
iptablesBoth -P OUTPUT DROP

# Allow loopback traffic
iptablesBoth -A INPUT -i lo -j ACCEPT
iptablesBoth -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptablesBoth -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Deny pinging
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
ip6tables -A INPUT -p icmpv6 --icmpv6-type echo-request -j DROP

# Allow ssh
## Incoming SSH connections
iptablesBoth -A INPUT -p tcp --dport 22 -j ACCEPT
iptablesBoth -A OUTPUT -p tcp --sport 22 -j ACCEPT
## Outgoing SSH connection (ie. GitHub, etc.)
iptablesBoth -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Allow DNS
iptablesBoth -A INPUT -p udp --sport 53 -j ACCEPT
iptablesBoth -A OUTPUT -p udp --dport 53 -j ACCEPT
## TCP is not needed for DNS, but sometimes TCP can apparently make an
## appearence on DNS requests so we allow it
iptablesBoth -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptablesBoth -A INPUT -p tcp --sport 53 -j ACCEPT

# Allow webtraffic
iptablesBoth -A INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT
iptablesBoth -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Allow proxy traffic
iptables -A INPUT -p tcp -s 192.168.154.1 --sport 3128 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.154.1 --dport 3128 -j ACCEPT
ip6tables -A INPUT -p tcp -s fe80::5054:ff:fe03:2300 --sport 3128 -j ACCEPT
ip6tables -A OUTPUT -p tcp -d fe80::5054:ff:fe03:2300 --dport 3128 -j ACCEPT

# Block everything else
iptablesBoth -A INPUT -j DROP
iptablesBoth -A OUTPUT -j DROP
iptablesBoth -A FORWARD -j DROP
