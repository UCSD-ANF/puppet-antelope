# @summary Install Antelope MCollective plugins
#
# This class installs MCollective plugins for Antelope on systems with
# Antelope installed. These plugins allow remote management of Antelope
# services via MCollective.
#
# @param plugin_basedir
#   Directory where MCollective plugins are stored (libdir)
# @param mco_etc
#   Directory where MCollective config files are kept
# @param ensure
#   Whether the plugins should be present or absent
# @param owner
#   File owner for installed plugins
# @param group
#   File group for installed plugins
# @param mode
#   File mode for installed plugins
# @param client_only
#   Install only client plugins when true
#
# @example Install MCollective plugins
#   include antelope::mco
#
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
