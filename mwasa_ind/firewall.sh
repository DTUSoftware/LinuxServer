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

# Deny pinging
iptablesBoth -A INPUT -p icmp --icmp-type echo-request -j DROP

# Allow ssh
iptablesBoth -A INPUT -p tcp --dport 22 -j ACCEPT
iptablesBoth -A OUTPUT -p tcp --sport 22 -j ACCEPT

# Allow DNS
iptablesBoth -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
iptablesBoth -A INPUT -p udp -m udp --sport 53 -j ACCEPT

# Allow webtraffic
iptablesBoth -A INPUT -p tcp --sport 80 -j ACCEPT
iptablesBoth -A INPUT -p tcp --sport 443 -j ACCEPT
iptablesBoth -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptablesBoth -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Block everything else
iptablesBoth -A INPUT -j DROP
iptablesBoth -A OUTPUT -j DROP
iptablesBoth -A FORWARD -j DROP
