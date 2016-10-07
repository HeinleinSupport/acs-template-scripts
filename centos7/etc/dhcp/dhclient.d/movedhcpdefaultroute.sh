#!/bin/bash
#
# /etc/dhcp/dhclient.d/movedhcpdefaultroute.sh
#
# Heinlein Support GmbH 2015 https://www.heinlein-support.de/
#
# Peter Fischer <p.fischer@heinlein-support.de>
# Stephan Seitz <s.seitz@heinlein-support.de>
#
# CentOS 7 with NetworkManager emulates dhclient-script
# with small changes.
#
# The resulting template should drive two scenarios:
# a) One interface w/ dhcp at that managed network.
#    for this, we don't need anything.
# b) Two interfaces. First interface in a defined and
#    named management network (though managed via dhcp)
#    plus a second managed or unmanaged network. That
#    second network does not need to be managed via ACS.
#
# To get this done, iproute2 is used. Please refer to
#   /etc/iproute2/rt_tables. If not already done,
#   echo "8 mgmt" >> /etc/iproute2/rt_table.
#
# This script triggers *only*, if the following variables
# match:
#
# Name of the first, managed interface
#iface="eth0"
iface="eth0"
#
# Network address of our management network
#mgmtnet="10.97.64.0"
mgmtnet="10.97.64.0"
#
# RT to use (needs to be present in /etc/iproute2/rt_tables)
#table="mgmt"
table="mgmt"
#
# Disable IPv6 at all on the management network
#disable_ipv6=1 # possible values 0/1
disable_ipv6=1
#
# Drop any incoming traffic on the management interface
#enable_firewall=1
enable_firewall=1
#
# allow SSH TCP/22 on the management interface if enable_firewall == 1
#fw_allow_ssh=1
fw_allow_ssh=1
#
# allow check_mk_agent TCP/6556 on the management interface if enable_firewall == 1
#fw_allow_checkmk=1
fw_allow_checkmk=1
#
# allow SNMP UDP/161 on the management interface if enable_firewall == 1
#fw_allow_snmp=1
fw_allow_snmp=1
#
# -------------------------------------------------------

tag=$(basename $0)

logmsg () {
  logger -t "$tag" "$*"
}

execlog () {
  logmsg "$*"
  $*
}


if [ "$DEVICE_IFACE" = "$iface" ]; then
  interface=$DEVICE_IFACE
  logmsg "Interface $iface found"
  if [ "_$reason" != "_STOP" ]; then
    logmsg "No reason is the most powerful element of style. (NM does not provide reasons like dhclient)"
    if [ "$new_network_number" = "$mgmtnet" ]; then
 
      logmsg "We are now joining the management network"

      # move the default route to our management rt_table
      # and add a rule for that interface IP to use the management rt_table
      execlog ip route del default via "$new_routers"
      execlog ip route add "$new_network_number"/"$new_subnet_mask" dev "$interface" src "$new_ip_address" table "$table"
      execlog ip route add default via "$new_routers" table "$table"
      execlog ip rule add from "$new_ip_address" lookup "$table"

      # disable IPv6 in our management network
      [ $disable_ipv6 -eq 1 ] && execlog sysctl net.ipv6.conf.${interface}.disable_ipv6=1

      # Enable a generic firewall rule to drop all incoming traffic
      if [ $enable_firewall -eq 1 ]; then
        execlog iptables -I FORWARD -i "$interface" -j DROP
        execlog iptables -I INPUT -i "$interface" -j DROP
        execlog iptables -I INPUT -i "$interface" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        if [ $fw_allow_ssh -eq 1 ]; then
          execlog iptables -I INPUT -i "$interface" -p tcp -m tcp --dport 22 -j ACCEPT
        fi
        if [ $fw_allow_checkmk -eq 1 ]; then
          execlog iptables -I INPUT -i "$interface" -p tcp -m tcp --dport 6556 -j ACCEPT
        fi
        if [ $fw_allow_snmp -eq 1 ]; then
          execlog iptables -I INPUT -i "$interface" -p udp -m udp --dport 161 -j ACCEPT
        fi
      fi
    fi
  elif [ "_$reason" = "_RELEASE" ]; then
    logmsg "Reason == RELEASE"
    if [ "$old_network_number" = "$mgmtnet" ]; then

      logmsg "We are now leaving the management network"

      # if our interface IP is gone, remove the rule to the management rt_table
      execlog ip rule del from "$old_ip_address" lookup "$table"

      # release IPv6 in our management network
      [ $disable_ipv6 -eq 1 ] && execlog sysctl net.ipv6.conf.${interface}.disable_ipv6=0

      # remove previous firewall rules
      if [ $enable_firewall -eq 1 ]; then
        execlog iptables -D FORWARD -i "$interface" -j DROP
        execlog iptables -D INPUT -i "$interface" -j DROP
        execlog iptables -D INPUT -i "$interface" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        if [ $fw_allow_ssh -eq 1 ]; then
          execlog iptables -D INPUT -i "$interface" -p tcp -m tcp --dport 22 -j ACCEPT
        fi
        if [ $fw_allow_checkmk -eq 1 ]; then
          execlog iptables -D INPUT -i "$interface" -p tcp -m tcp --dport 6556 -j ACCEPT
        fi
        if [ $fw_allow_snmp -eq 1 ]; then
          execlog iptables -D INPUT -i "$interface" -p udp -m udp --dport 161 -j ACCEPT
        fi
      fi
    fi
  fi
fi

