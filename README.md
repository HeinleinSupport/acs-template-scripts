acs-template-scripts
====================

Preface
-------

We're running ACS with different kinds of networks, some of them
are completely unmanaged by ACS (say: Quick Cloud with no Services)

To get the usual password and ssh-key scripts working, the
respective VM need to reside at a managed network with at least
DHCP Service enabled.

Therefor we decided to introduce a "management" network with
following goals:

- Get functional Password Reset / SSH management.
- Get access to the VM even if the production network is unconfigured, broken or simply down.
- Have the "management" completely unrelated to any production network.
- Have it working in a "normal" way with any managed network.

We've made following design decisions, which are configurable inside the respective scripts:

- Keep the network behaviour as close as possible the the respecitve distro-default.
- Use a user "vmadmin" as unprivileged user instead of "root"
- Define a "management" network with following paradigms:
  - Always connected as "first" or "primary" network
  - Trigger only, if the network address is 10.97.64.0
- Have a /root/newtemplate.sh handy to clean-up everything to prepare new (next) template.


Distributions
-------------

We've successfully added that behaviour to

- Debian 8 (isc-dhcp)
- Ubuntu 14.04 (isc-dhcp)
- CentOS 7 (NetworkManager)
- SuSE Leap 42 (wicked)

License
-------

GNU General Public License, version 2 / GPLv2

Copyright
---------

Heinlein Support GmbH 2016 https://www.heinlein-support.de/

Authors
-------

Stephan Seitz <s.seitz@heinlein-support.de>
Peter Fischer <p.fischer@heinlein-support.de>
Rober Sander <r.sander@heinlein-support.de>


