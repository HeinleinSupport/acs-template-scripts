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
	aptitude update -y
	aptitude dist-upgrade -y
fi

apt-get clean -y
apt-get autoclean -y
apt-get autoremove -y

rm -rf /root/.ssh /home/vmadmin/.ssh /home/vmadmin/.bash_history
rm -rf /root/.aptitude /root/.bash_history /root/.viminfo
rm -f /etc/udev/rules.d/70*
rm -f /var/lib/dhcp/dhclient.*
rm -f /etc/ssh/*key*
if [ -f /var/log/audit/audit.log ]; then cat /dev/null > /var/log/audit/audit.log; fi
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null
rm -f /var/log/upstart/*.log /var/log/upstart/*.log.*.gz
rm -f /var/log/auth.log

echo "localhost" > /etc/hostname
hostname -b -F /etc/hostname

cat > /etc/hosts << _EOF_
127.0.0.1       localhost.localdomain localhost

###IP###	###FQDN### ###HOSTNAME###

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

_EOF_


history -c
unset HISTFILE

sync && sync && sync
echo o > /proc/sysrq-trigger
