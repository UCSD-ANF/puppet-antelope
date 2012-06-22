# This class installs a syncronization script for copying an existing
# golden master Antelope installation.
#
# The script uses rsync under the hood, and connects to the source
# system over SSH using the sync_user and sync_host variables to
# compute the ssh credentials
#
# It depends on passwordless SSH being set up. It also needs a working
# copy of rsync installed in /usr/bin on Linux or /opt/csw/bin on Solaris
#
# Autorequires:
#  * User[$sync_user]
#  * Group[$sync_group]
#  * File[/usr/local/bin]
#  * File[/usr/local/etc]
#
# Parameters:
# [*sync_user*] - the source username for the rsync command
#
# [*sync_host*] - the source hostname for the rsync command
class antelope::sync (
  $sync_user = $antelope::params::sync_user,
  $sync_host = $antelope::params::sync_host
) inherits antelope::params {

  ### Class local variables

  $basedir   = '/usr/local'
  $confdir   = "$basedir/etc"
  $bindir    = "$basedir/bin"
  $rsync_bin = $::osfamily ? {
    'Solaris' => '/opt/csw/bin/rsync',
    default   => '/usr/bin/rsync',
  }

  $manage_file_owner = 'root'
  $manage_file_group = 'bin'

  ### Managed resources

  # Main synchronization script
  file { 'antelope_sync' :
    ensure  => present,
    path    => "${bindir}/antelope_sync",
    mode    => '555',
    owner   => $manage_file_owner,
    group   => $manage_file_group,
    content => template('antelope/sync/antelope_sync.erb'),
    require => [
      File[$bindir],
      User[$manage_file_owner],
      Group[$manage_file_group],
    ],
  }

  # Exclude and include lists
  file { 'rsync_exclude':
    ensure => present,
    path   => "${confdir}/rsync_exclude",
    mode   => '444',
    owner  => $manage_file_owner,
    group  => $manage_file_group,
    source => 'puppet:///modules/antelope/files/sync/rsync_exclude',
    require => [
      File[$confdir],
      User[$manage_file_owner],
      Group[$manage_file_group],
    ],
  }

  file { 'rsync_include':
    ensure => present,
    path   => "${confdir}/rsync_include",
    mode   => '444',
    owner  => $manage_file_owner,
    group  => $manage_file_group,
    source => 'puppet:///modules/antelope/files/sync/rsync_include',
    require => [
      File[$confdir],
      User[$manage_file_owner],
      Group[$manage_file_group],
    ],
  }
}
