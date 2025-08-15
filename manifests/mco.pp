#
# Class: antelope::mco
#
# Install Antelope MCollective Plugins
#
# This is a generic class that will install MCollective Plugins for Antelope on
# systems with Antelope installed.
#
# For background on MCollective directories, see
# https://docs.puppetlabs.com/mcollective/deploy/plugins.html#method-2-copying-plugins-into-the-libdir
#
# *plugin_basedir* is where MCollective plugins are stored on your system, aka
# the "libdir".
#
# *mco_etc* is where MCollective config files are kept
class antelope::mco (
  Stdlib::Absolutepath      $plugin_basedir = '/usr/libexec/mcollective',
  Stdlib::Absolutepath      $mco_etc        = '/etc/mcollective',
  Enum['present', 'absent'] $ensure         = 'present',
  Antelope::User            $owner          = 'root',
  Antelope::Group           $group          = 'root',
  String                    $mode           = '0644',
  Boolean                   $client_only    = false,
) {
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
  file { "${plugin_basedir}/agent/antelope.ddl":
    source => 'puppet:///modules/antelope/mco/antelope.ddl',
  }

  # Only install this on servers
  file { "${plugin_basedir}/agent/antelope.rb":
    ensure => $server_ensure,
    source => 'puppet:///modules/antelope/mco/antelope.rb',
  }
}
