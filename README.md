# 62501 Linux Server and Network: Mandatory Assignment 3

## How to use

In the folder you will find a run.sh file, which will setup all of the services automatically, though you will have to interact in order to type in the Tripwire password.

## Security discussion

Through the configuration, which this script will perform, the server will be secured by a firewall (iptables), which denies most forms of traffic.

The server will also log and notify the administrators (through the host-based IDS Tripwire and Logwatch), and sets up a local DHCP server for clients to browse the internet through.
This internet connection is sequired by the firewall and a MitM-proxy called Squid, which will log activity on the network, and block things which we do not want clients to access, ie. facebook.com.

The SSH connection also gets secured, by turning off password logins, only allowing the SSH-keys from the script to work.

### What else could be done

First of all, you should update the distro on the server to a version that still recieves security updates, and supports newer versions of packages with bug-fixes.

You could create a honeypot on the network, to try and catch whether other people are trying to hack into your network.

You can also implement security measures against common low-level attacks or checks, like nmap.

It would also be a genius idea to take backups of the server, and remembering the 3-2-1 backup rule, so that you could easily recover from any happenings, be they accidental or by bad actors, for example an IT intern messing something up (they shouldn't have sudo anyway), or ransomware.
