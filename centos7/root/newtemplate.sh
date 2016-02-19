#! /bin/bash

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

if [ $(ping -c1 8.8.8.8 > /dev/null 2>&1; echo $?) -eq 0 ]
then
	yum update -y
fi

rm -rf /etc/ssh/*key*

rm -fv /root/.bash_history /root/.viminfo
rm -rfv /home/vmadmin/.bash_history /home/vmadmin/.viminfo /home/vmadmin/.ssh
rm -fv /etc/udev/rules.d/*-net.rules /etc/udev/rules.d/*persistent*
rm -fv /tmp/*

yum -y clean all
rm -f /root/anaconda-ks.cfg
rm -f /root/install.log
rm -f /root/install.log.syslog
find /var/log -type f -delete

for i in `find /etc/udev/rules.d/ -name "*persistent*"`; do ln -sf /dev/null $i; done


rm -f /var/lib/NetworkManager/*.lease
rm -f /var/lib/dhcp/dhclient.*
rm -f /etc/ssh/*key*


if [ -f /var/log/audit/audit.log ]; then cat /dev/null > /var/log/audit/audit.log; fi
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null

echo "localhost" > /etc/hostname
hostname -b -F /etc/hostname

history -c
unset HISTFILE

sync && sync && sync
echo o > /proc/sysrq-trigger
