#!/bin/bash
#
# Network configuration for basic server
# ­ using '/bin/ip'
#
# Note: hostname and the lo interface are
# set up by other services
#
ip="/bin/ip"
dev=eth0
dev2=eth1
dmz=dmz0
myIP="192.168.150.14/25"
my_intIP="192.168.154.1/24"
my_dmzIP="10.22.0.0/16"
# For XX and YYY refer to the note "Server IP Addresses"
router="192.168.150.1"
#
case "$1" in
start)
  echo "Starting the network"
  #
  # 1. The ethernet interface
  #
  $ip link set up dev $dev
  $ip link set up dev $dev2
  $ip addr add $myIP dev $dev broadcast +
  $ip addr add $my_intIP dev $dev2 broadcast +
  #
  # 2. The default gateway
  #
  $ip route add default dev $dev via $router scope global
  #
  # 3. The DMZ interface
  #
  $ip link add name $dmz type dummy
  $ip addr add $my_dmzIP dev $dmz
  $ip link set up dev $dmz
  #
  # Add a route to the 'internal' subnet
  #
  # $ip route add $my_int_net dev $dev2
  #
  # 4. Enable routing
  #
  echo 1 > /proc/sys/net/ipv4/ip_forward
  #
  # 5. disable ICMP redirects
  #
  sysctl -w net.ipv4.conf.all.send_redirects=0

  ;;
stop)
  echo "Stopping the network"
  $ip route del default
  $ip addr del $myIP dev $dev
  $ip link set down dev $dev
  $ip addr del $my_intIP dev $dev2
  $ip link set down dev $dev2
  $ip addr del $my_dmzIP dev $dmz
  $ip link set down dev $dmz
  $ip link delete $dmz
  ;;
restart)
  # stop the network and start it again
  $0 stop
  $0 start
  ;;
*)
  echo "Usage $0 [start|stop|restart]"
esac
