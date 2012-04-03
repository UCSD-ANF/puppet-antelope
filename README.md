# Antelope Module for Puppet

This is a Puppet Module to provide support for the Antelope Real-Time
Monitoring System by Boulder Real-Time Technologies
http://brtt.com

## Author

Geoff Davis <gadavis@ucsd.edu>

## Requirements

* Puppet version >= 2.6.x
* create_resources library function. This ships with Puppet >= 2.7.x, but is also [https://github.com/puppetlabs/puppetlabs-create_resources](available as a module for 2.6 from:
* [https:///github.com/example42/puppi](puppi module) for some additional parser functions.
* [https://github.com/puppetlabs/puppetlabs-stdlib](stdlib module) from PuppetLabs. Ships with Puppet Enterprise, also available on the Module Forge and on Github
* osfamily fact. Supported by Facter 1.6.1+. If you do not have facter 1.6.1 in your environment, the following manifests will provide the same functionality in site.pp (before declaring any node):

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
Sets up a basic Antelope environment. The optional rtsystems parameter automatically configures antelope::instance resources.

Basic instanciation of the Antelope class

     class { 'antelope': }

Instanciation with a default antelope::instance set up to manage a real-time system

     class { 'antelope':
       instances => '/rtsystems/default',
     }

The rtsystems parameter also takes a hash of hashes, which can be useful for configuring multiple instances with different users from an External Node Classifier

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
