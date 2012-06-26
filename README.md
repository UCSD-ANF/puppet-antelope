# Antelope Module for Puppet

Version 0.5.1

This is a Puppet Module to provide support for the Antelope Real-Time
Monitoring System by Boulder Real-Time Technologies
http://brtt.com

## Author

Geoff Davis <gadavis@ucsd.edu>

## Requirements

* Puppet version >= 2.6.x
* create\_resources library function. This ships with Puppet >= 2.7.x, but is also [https://github.com/puppetlabs/puppetlabs-create_resources](available as a module for 2.6)
* [https:///github.com/example42/puppi](example42-puppi module) for some additional parser functions. GitHub only at this point
* [https://github.com/puppetlabs/puppetlabs-stdlib](puppetlabs-stdlib module) from PuppetLabs. Ships with Puppet Enterprise, also available on the Module Forge and on Github
* osfamily fact. Supported by Facter 1.6.1+. Or you can use the code blurb below
* [https://github.com/ripienaar/puppet-concat](ripienaar-concat module) - also available on the forge. Only required if managing the antelope_services fact - see below
* [https://github.com/UCSD-ANF/puppet-php](camptocamp-php module with ANF customizations). Only required if using the antelope::php class.
* A supported Operating System for Antelope. Currently Solaris, Linux, or OS X

If you do not have facter 1.6.1 in your environment, the following manifest code will provide the same functionality as osfamily. It should be placed in site.pp (before declaring any node):

    if ! $::osfamily {
      case $::operatingsystem {
        'RedHat', 'Fedora', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL': {
          $osfamily = 'RedHat'
        }
        'ubuntu', 'debian': {
          $osfamily = 'Debian'
        }
        'SLES', 'SLED', 'OpenSuSE', 'SuSE': {
          $osfamily = 'Suse'
        }
        'Solaris', 'Nexenta': {
          $osfamily = 'Solaris'
        }
        default: {
          $osfamily = $::operatingsystem
        }
      }
    }


## Usage

### The antelope services fact
By default, this module will try to create a fact called antelope_services which contains a comma separated list of all of the system services created by the antelope::instance defined types. The creation of this fact depends on a couple of different modules and resources, which you may not want to configure. If you want to skip creating this fact, set the manage_instances_fact parameter to the main antelope class to false, and set the manage_fact parameter to false for each antelope::instance that you manually define.

### antelope

Sets up a basic Antelope environment. The optional dirs or instances parameters automatically configures antelope::instance resources.

#### Basic usage of the Antelope class

     class { 'antelope': }

#### With the dirs parameter

This form creates a default antelope::instance set up to manage a real-time system as provided in the 'dirs' parameter

     class { 'antelope':
       dirs => '/rtsystems/default',
     }

This form creates an antelope::instance but does not create the antelope_services fact

     class { 'antelope':
       dirs => '/rtsystems/default',
       manage_instance_fact => false,
     }

#### With the instances Parameter

The instances parameter, when used instead of dirs, takes a hash of hashes. This can be useful for configuring multiple instances with different users from an External Node Classifier without having to explicitely declare separate antelope::instance definitions.

     class { 'antelope':
       intances => {
         antelope => {
           user => 'rt',
           dirs => ['/rtsystems/foo', '/rtsystems/bar'],
         },
         antelope-baz => {
           user => 'basil',
           dirs => '/rtsystems/baz',
         },
       }
     }

### antelope::instance
Configure an instance of Antelope. More than one can be configured. Useful for real-time systems running as different users. Note that only the antelope instance will show up in the antelope_services fact

     antelope::instance { 'antelope' :
       user => 'rt',
       dirs => ['/rtsystems/foo', '/rtsystems/bar'],
    }

    antelope::instance { 'antelope-baz' :
       user        => 'basil',
       dirs        => '/rtsystems/baz',
       manage_fact => false, # don't create an entry in the antelope_services fact for this instance.
    }

Same configuration as above, but no antelope_services fact is created:

     antelope::instance { 'antelope' :
       user        => 'rt',
       dirs        => ['/rtsystems/foo', '/rtsystems/bar'],
       manage_fact => false,
    }

    antelope::instance { 'antelope-baz' :
       user        => 'basil',
       dirs        => '/rtsystems/baz',
       manage_fact => false,
    }

### antelope::sync
Installs a wrapper around rsync for copying Antelope from a golden master. Includes the ability to synchronize an optional site-specific tree.

You must at a minimum declare the sync_host parameter with this class. This can be done either by passing sync_user as a parameter or by declaring a top-scope variable $::antelope_sync_host

    class { 'antelope::sync' :
      sync_host => 'buildhost.example.net',
      site_tree => '/opt/mysite',
    }

Same as above using global variables:

    # in site.pp
    $antelope_sync_host = 'buildhost.example.net'
    $antelope_site_tree = '/opt/mysite'

    # elsewhere:
    include antelope::sync

### antelope::php
Enables the Antelope PHP bindings in php.ini

Requires the camptocamp-php module with ANF customizations (shown under the Requirements section)

This will install the PHP bindings using the latest installed version of antelope, as determined by the antelope_latest_version fact

    include antelope::php

Same as above, but being explicit with the version string

    class { 'antelope::php' : version => '5.2-64' }
