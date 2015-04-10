# Antelope Module for Puppet

Version 0.8.11

This is a Puppet Module to provide support for the Antelope Real-Time
Monitoring System by [Boulder Real-Time Technologies][brtt]

[brtt]: http://www.brtt.com

## Author

Geoff Davis <gadavis@ucsd.edu>

## Requirements

* Puppet version >= 2.6.x
* `create_resources` library function. This ships with Puppet >= 2.7.x, but is
 also available as a [module for 2.6 on GitHub][puppetlabs-create_resources]
* [example42-puppi][example42-puppi] module for some additional parser
 functions. GitHub only at this point
* [puppetlabs-stdlib][puppetlabs-stdlib] module from PuppetLabs. Ships with
 Puppet Enterprise, also available on the Module Forge and on Github
* `osfamily` fact. Supported by Facter 1.6.1+. Or you can use the code blurb
 below
* [puppetlabs-concat][puppetlabs-concat] module - also available on the forge.
 Only required if managing the `antelope_services` fact - see below
* [camptocamp-php module with ANF customizations][ucsd-puppet-php]. Only
 required if using the `antelope::php` class.
* A supported Operating System for Antelope. Currently Solaris, Linux, or OS X

[puppetlabs-create_resources]: https://github.com/puppetlabs/puppetlabs-create_resources
[example42-puppi]: https:///github.com/example42/puppi
[puppetlabs-stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppetlabs-concat]: https://github.com/puppetlabs/puppetlabs-concat
[ucsd-puppet-php]: [https://github.com/UCSD-ANF/puppet-php]

If you do not have facter >= 1.6.1 in your environment, the following manifest
code will provide the same functionality as `osfamily`. It should be
placed in `site.pp` (before declaring any node):

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

## Facts

This module includes Facter facts for several things related to Antelope. It
also optionally manages the contents of a fact called `antelope_services`,
described below.

### The `antelope services` fact
By default, this module will try to create a fact called `antelope_services`
which contains a comma separated list of all of the system services created by
the `antelope::instance` defined types. The creation of this fact depends on a
couple of different modules and resources, which you may not want to configure.
If you want to skip creating this fact, set the `manage_instances_fact`
parameter to the main `antelope` class to false, and set the `manage_fact`
parameter to false for each `antelope::instance` that you manually define.

### Other facts

* `antelope_versions`       - All versions of Antelope installed on the system
* `antelope_latest_version` - The newest version of Antelope installed on the system
* `antelope_latest_perl`    - the version of Perl that ships with `antelope_latest_version`

## Classes

### Class `antelope`

Sets up a basic Antelope environment. The optional dirs or instances parameters
automatically configures `antelope::instance` resources.

Please look at the class definition in init.pp for additional parameters that
can control behavior, such as `manage_rtsystemdirs`

#### Basic usage of the Antelope class

     class { 'antelope': }

#### With the dirs parameter

This form creates a default `antelope::instance` set up to manage a real-time
system as provided in the `dirs` parameter

     class { 'antelope':
       dirs => '/rtsystems/default',
     }

This form creates an `antelope::instance` but does not create the
`antelope_services` fact

     class { 'antelope':
       dirs => '/rtsystems/default',
       manage_instance_fact => false,
     }

#### With the instances Parameter

The `instances` parameter, when used instead of dirs, takes a hash of hashes.
This can be useful for configuring multiple instances with different users from
an External Node Classifier without having to explicitely declare separate
`antelope::instance` definitions.

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

### Class `antelope::mco`
Install an MCollective Agent for managing Antelope.

    include antelope::mco

### Defined Type `antelope::instance`
Configure an instance of Antelope. More than one can be configured. Useful for
real-time systems running as different users. Permissions on the rtexec.pf in
each entry in dirs are managed unless `manage_rtsystemdirs` is false.
Note that in the example below, _only the `antelope` instance will show up_
in the `antelope_services` fact

     antelope::instance { 'antelope' :
       user => 'rt',
       dirs => ['/rtsystems/foo', '/rtsystems/bar'],
    }

    antelope::instance { 'antelope-baz' :
       user        => 'basil',
       dirs        => '/rtsystems/baz',
       manage_fact => false, # don't create an entry in the antelope_services fact for this instance.
    }

Same configuration as above, but no `antelope_services` fact is created:

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

### Defined Type `antelope::sync`
Installs a wrapper around rsync for copying Antelope from a golden master.
Includes the ability to synchronize an optional site-specific tree.

You must at a minimum declare the `host` parameter with this class. This
can be done either by passing `host` as a parameter or by declaring a
top-scope variable `$::antelope_sync_host`

    class { 'antelope::sync' :
      host => 'buildhost.example.net',
      site_tree => '/opt/mysite',
    }

Same as above using global variables:

    # in site.pp
    $antelope_sync_host = 'buildhost.example.net'
    $antelope_site_tree = '/opt/mysite'

    # elsewhere:
    include antelope::sync

### Defined Type `antelope::php`
Enables the Antelope PHP bindings in `php.ini`

Requires the camptocamp-php module with ANF customizations (shown under the
 Requirements section)

This will install the PHP bindings using the latest installed version of
antelope, as determined by the `antelope_latest_version` fact

    include antelope::php

Same as above, but being explicit with the version string

    class { 'antelope::php' : version => '5.2-64' }

### Defined Type `antelope::versioned_site_pf`
Put a site.pf in place for a particular version of Antelope. Allows multiple
 resources to be declared for different versions of Antelope, as well as
 arbitrary staging locations.

#### Parameters

##### Parameters affecting `antelope::versioned_site_pf`'s behavior:

*[version]*
 The version of Antelope that this site.pf instance will belong to.
 Defaults to `$title`. This is the _namevar_.

*[source]*
 If set, this file is copied directly with no template evaluation
 performed. 'template' and 'source' cannot both be set. Defaults to
 undef.

*[content]*
 If set, this is used as the file's contents. This allows you to
 specify your own template in case the default template doesn't work
 for you. Defaults to template('puppet/site.pf.erb'). It is an error
 to define both template and source at the same time.

*[path]*
 If set, override the default filename. Defaults to
 '/opt/antelope/$version/data/pf/site.pf'

##### Parameters affecting template evaluation:

*[mailhost]*
 Accessible IP address or hostname of system running mail relay agent.
 Defaults to ''

*[mail_domain]*
 Used by site.pf template evaluation. Domain name for outgoing mail
 -- e.g., 'brtt.com'. Defaults to `$::fqdn`

*[default_seed_network]*
 Used by site.pf template evaluation. Used in miniseed headers. This
 code is officially assigned so don't pick one arbitrarily. Put that
 code in here, or use the default 'XX' code.

*[originating_organization]*
 Used by site.pf template evaluation. Used in SEED volumes in the
 '010 blockette'. Fill in the long name of your organization or
 institution here. Default is ''.

*[institution]*
 Maps to the big-'I' `Institution` parameter in `site.pf`. Short code
 part of the author field in the origin table, e.g., UCSD.
 The combination of this short code and the username in the Antelope
 origin table can only be 14 characters after one is burned for a
 colon delimiter, e.g. `$INSTITUTION:$USER`. Default is 'XXXX'.

#### Example

Install a site.pf for the latest version of Antelope. Uses the
`antelope_latest_version` fact provided by this module.

    antelope::versioned_site_pf( $::antelope_latest_version :
      mail_relay               => 'smtp.ucsd.edu',
      mail_domain              => 'ucsd.edu',
      default_seed_network     => 'TA',
      originating_organization => 'UC San Diego',
      institution              => 'UCSD',
    }

Install a site.pf for Antelope version 5.3 in $ANTELOPE/data/pf

    antelope::versioned_site_pf { '5.3' }

place a site.pf in a real-time system directory

    antelope::versioned_site_pf { 'rtsystems/www' :
      version => '5.3',
	  path => '/export/home/rt/rtsystems/www/pf/site.pf'
    }

### Defined type `antelope::versioned_license_pf`

Define a license.pf parameter file for a particular version of
Antelope.

This is a define rather than a class because we need to be able to
support more than one version of Antelope being installed on a
particular system for testing.

#### Parameters

##### Parameters affecting behavior of this define:

*[version]*
The version of Antelope that this license.pf instance will belong to.
Defaults to `$title`. This is the _namevar_.

*[source]*
If set, this file is copied directly with no template evaluation
performed. **`template` and `source` cannot both be set.** Defaults to
`undef`.

*[content]*
If set, this is used as the file's contents. This allows you to
specify your own template in case the default template doesn't work
for you. Defaults to `template('puppet/license.pf.erb')`. **It is an
error to define both template and source at the same time.**

*[replace]*
If true or yes, the contents of the file will be replaced if it
exists. If false or no (the default) any existing contents are left
in place

*[path]*
If set, this is used as the filename for the license file. This allows you
specify an arbitrary location for license files for staging purposes.
Defaults to `/opt/antelope/$version/data/pf/license.pf`

##### Parameters affecting template evaluation:

*[license_keys]*
An array containing license keys, one per array element.

*[expiration_warnings]*
If false, the parameter `no_more_expiration_warnings` is set in
 license.pf. If true, it's not set in license.pf

#### Examples

Set the license.pf for the latest version of Antelope:

    antelope::versioned_license_pf( $::antelope_latest_version :
      license_keys    => [
        'tabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo.ucsd.edu Antelope 5.1',
        'tbbadef1234567890abcdef1234567890abcdef12 2014 May 01 # node bar.ucsd.edu Antelope 5.1',
      ],
      replace => true,
    }

## Facter Facts

### antelope_contrib_basedir

Antelope versions 5.5 and higher (actually started in 5.4post) now relocate the
Antelope contributed code repository (contrib) to a subdirectory. This fact is
a hash of versions of Antelope installed on the system and what subdirectory
contrib lives in. Returns an empty string if not relocated, and "/contrib" if
it is for each version.

Should look something like this:

```
{"5.2-64"=>"", "5.3"=>"", "5.4"=>"", "5.4post"=>"/contrib"}
```

### antelope_latest_version

Shows the newest version of Antelope installed on the system

### antelope_latest_perl

The version of Perl that ships with the latest version of Antelope, as provided
in the antelope_latest_version fact.

### antelope_latest_python

The version of Python that ships with the latest version of Antelope, as
provided in the antelope_latest_version fact.

### antelope_versions

Legacy-style fact that provides a comma-separated list of Antelope versions
installed on the system.

### antelope_versions_array

New-style fact that provides an array of Antelope versions installed on the
system.

### antelope_versions_supports_ald_proxy

Returns an comma-delimited string of all system versions of Antelope that support the Antelope License Proxy.
E.G.
```
'5.3,5.4,5.5'
```

### antelope_versions_supports_ald_proxy_array

Returns an array of all system versions of Antelope that support the Antelope License Proxy.
E.G.
```
['5.3','5.4','5.5']
```

