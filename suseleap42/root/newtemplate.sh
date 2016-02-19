#!/bin/bash
#
# /root/newtemplate.sh
#
# Heinlein Support GmbH 2015 https://www.heinlein-support.de/
#
# Peter Fischer <p.fischer@heinlein-support.de>
# Stephan Seitz <s.seitz@heinlein-support.de>
#
#
# purpose: clean up!
#
# run this script after any modifications as prerequisite
# before creating a new template from this (then) stopped VM.
#

rm -rf /etc/ssh/*key*

rm -rfv /root/.bash_history /root/.viminfo /home/vmadmin/.ssh /home/vmadmin/.bash_history
rm -f /var/lib/wicked/*
rm -fv /etc/udev/rules.d/*-net.rules /etc/udev/rules.d/*persistent*

zypper --non-interactive clean
if [ $(ping -c1 8.8.8.8 > /dev/null 2>&1; echo $?) -eq 0 ]
then
	zypper --non-interactive refresh
	zypper --non-interactive update
fi

rm -f /root/install.log
rm -f /root/install.log.syslog
find /var/log -type f -delete
touch /var/log/lastlog

#rm -f /var/lib/random-seed 
#grubby --update-kernel=ALL --args="crashkernel=0@0 vga=791"

#bz912801
# prevent udev rules from remapping nics
for i in `find /etc/udev/rules.d/ -name "*persistent*"`; do ln -sf /dev/null $i; done

#bz 1011013
# set eth0 to recover from dhcp errors
#echo PERSISTENT_DHCLIENT="1" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# no zeroconf
#echo NOZEROCONF=yes >> /etc/sysconfig/network

# disable IPv6
#echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
#echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
#the above prevents proper functioning of postfix and possibly others and don't want to start customising their config
#echo NETWORKING_IPV6=no >> /etc/sysconfig/network
#echo IPV6INIT=no >> /etc/sysconfig/network

#cd /etc/rc.d/init.d
#wget https://raw.githubusercontent.com/shapeblue/cloudstack-scripts/master/cloud-set-guest-password-centos -O cloud-set-guest-password --no-check-certificate
#wget https://raw.githubusercontent.com/shapeblue/cloudstack-scripts/master/cloud-set-guest-sshkey-centos -O cloud-set-guest-sshkey --no-check-certificate
#chmod +x cloud-set-guest-password
#chmod +x cloud-set-guest-sshkey

#chkconfig --add cloud-set-guest-password
#chkconfig --add cloud-set-guest-sshkey
#chkconfig cloud-set-guest-password on
#chkconfig cloud-set-guest-sshkey on

#passwd --expire root

history -c
unset HISTFILE

sync && sync && sync
echo o > /proc/sysrq-trigger

