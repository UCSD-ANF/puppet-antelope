# Antelope Module for Puppet

Version 0.4

This is a Puppet Module to provide support for the Antelope Real-Time
Monitoring System by Boulder Real-Time Technologies
http://brtt.com

## Author

Geoff Davis <gadavis@ucsd.edu>

## Requirements

* Puppet version >= 2.6.x
* create_resources library function. This ships with Puppet >= 2.7.x, but is also [https://github.com/puppetlabs/puppetlabs-create_resources](available as a module for 2.6 from:
* [https:///github.com/example42/puppi](example42-puppi module) for some additional parser functions. GitHub only at this point
* [https://github.com/puppetlabs/puppetlabs-stdlib](puppetlabs-stdlib module) from PuppetLabs. Ships with Puppet Enterprise, also available on the Module Forge and on Github
* osfamily fact. Supported by Facter 1.6.1+.
* [https://github.com/ripienaar/puppet-concat](ripienaar-concat module) - also available on the forge

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

### antelope

Sets up a basic Antelope environment. The optional dirs or instances parameters automatically configures antelope::instance resources.

#### Basic usage of the Antelope class

     class { 'antelope': }

#### With the dirs parameter

This form creates a default antelope::instance set up to manage a real-time system as provided in the 'dirs' parameter

     class { 'antelope':
       dirs => '/rtsystems/default',
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
Configure an instance of Antelope. More than one can be configured. Useful for real-time systems running as different users.

     antelope::instance { 'antelope' :
       user => 'rt',
       dirs => ['/rtsystems/foo', '/rtsystems/bar'],
    }

    antelope::instance { 'antelope-baz' :
       user => 'basil',
       dirs => '/rtsystems/baz',
    }
