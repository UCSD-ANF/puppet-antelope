# This class installs a syncronization script for copying an existing
# golden master Antelope installation.
#
# The script uses rsync under the hood, and connects to the source
# system over SSH using the sync_user and sync_host variables to
# compute the ssh credentials
#
# It depends on passwordless SSH being set up. It also needs a working
# copy of rsync installed in /usr/bin on Linux and Darwin or
# /opt/csw/bin on Solaris
#
# Autorequires:
#  * File[/usr/local/bin]
#  * File[/usr/local/etc]
#
# Parameters:
#
# [*sync_host*] - the source hostname for the rsync command
# REQUIRED PARAMETER, MUST BE SPECIFIED TO USE THIS CLASS.
# Can also be specified by the global variable
# $::antelope_sync_host
#
# [*sync_user*] - the source username for the rsync command
# Can also be specified by the global variables $::antelope_sync_user
# or $::antelope_user. Defaults to 'rt'
#
# [*site_tree*] - optional site-local Antelope tree to synchronize.
# Defaults to undef. Example value is /opt/anf
# Can also be specified with the global variable $::antelope_site_tree
#
class antelope::sync (
  $sync_user = $antelope::params::sync_user,
  $sync_host = $antelope::params::sync_host,
  $site_tree = $antelope::params::site_tree
) inherits antelope::params {

  ### Validate variables
  if !$sync_host {
    fail('You must specify a value for sync_host. Either pass it as a parameter or defined the global variable \$::antelope_sync_host')
  }

  ### Class local variables

  $basedir   = '/usr/local'

  $manage_file_owner = 'root'
  $manage_file_group = $::osfamily ? {
    'Solaris' => 'bin',
    'RedHat'  => 'root',
    'Darwin'  => 'wheel',
    default   => 'root',
  }

  ### The following variables are used in template evaluation
  $confdir   = "$basedir/etc"
  $bindir    = "$basedir/bin"
  $rsync_bin = $::osfamily ? {
    'Solaris' => '/opt/csw/bin/rsync',
    default   => '/usr/bin/rsync',
  }
  $sync_dirs = flatten(['/opt/antelope', $site_tree ])

  ### Managed resources

  # Main synchronization script
  file { 'antelope_sync' :
    ensure  => present,
    path    => "${bindir}/antelope_sync",
    mode    => '555',
    owner   => $manage_file_owner,
    group   => $manage_file_group,
    content => template('antelope/sync/antelope_sync.erb'),
    require => File[$bindir],
  }

  # Exclude and include lists
  file { 'rsync_exclude':
    ensure => present,
    path   => "${confdir}/rsync_exclude",
    mode   => '444',
    owner  => $manage_file_owner,
    group  => $manage_file_group,
    source => 'puppet:///modules/antelope/files/sync/rsync_exclude',
    require => File[$confdir],
  }

  file { 'rsync_include':
    ensure => present,
    path   => "${confdir}/rsync_include",
    mode   => '444',
    owner  => $manage_file_owner,
    group  => $manage_file_group,
    source => 'puppet:///modules/antelope/files/sync/rsync_include',
    require => File[$confdir],
  }
}
