puppet-antelope
===============

This is a Puppet Module to provide support for the Antelope Real-Time
Monitoring System by Boulder Real-Time Technologies
http://brtt.com

Author
------

Geoff Davis <gadavis@ucsd.edu>

Requirements
------------

* Puppet version >= 2.6.x
* create_resources library function. This ships with Puppet >= 2.7.x,
   but is also available as a module for 2.6 from:
   https://github.com/puppetlabs/puppetlabs-create_resources
* puppi module (for some additional parser functions). Source:
   https://github.com/example42/puppi
* stdlib module from PuppetLabs. Ships with Puppet Enterprise, also
   available on the Module Forge and on Github:
   https://github.com/puppetlabs/puppetlabs-stdlib
