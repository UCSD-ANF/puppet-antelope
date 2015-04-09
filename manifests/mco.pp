#
# Class: antelope::mco
#
# Install Antelope MCollective Plugins
#
# This is a generic class that will install MCollective Plugins for Antelope on
# systems with Antelope installed.
#
# For background on MCollective directories, see https://docs.puppetlabs.com/mcollective/deploy/plugins.html#method-2-copying-plugins-into-the-libdir
#
# *plugin_basedir* is where MCollective plugins are stored on your system, aka the "libdir".
#
# *mco_etc* is where MCollective config files are kept
class antelope::mco(
  $plugin_basedir = 'UNSET',
  $mco_etc     = '/etc/mcollective',
  $ensure      = 'present',
  $owner       = 'root',
  $group       = 'root',
  $mode        = '0644',
  $client_only = false,
) {

  validate_re($ensure, '(present|absent)')

  $real_plugin_basedir = $plugin_basedir ? {
    'UNSET' => $::osfamily ? {
      'Debian' => '/usr/share/mcollective/plugins',
      default  => '/usr/libexec/mcollective',
    },
    default => $plugin_basedir,
  }

  $server_ensure = $client_only ? {
    true         => 'absent',
    default      => $ensure,
  }

  File {
    ensure => $ensure,
    group  => $group,
    mode   => $mode,
    owner  => $owner,
  }

  # Installed on MCO clients (management stations) and servers
  file {"${real_plugin_basedir}/agent/antelope.ddl":
    source => 'puppet:///modules/antelope/mco/antelope.ddl',
  }

  # Only install this on servers
  file {"${real_plugin_basedir}/agent/antelope.rb":
    ensure => $server_ensure,
    source => 'puppet:///modules/antelope/mco/antelope.rb',
  }

}
