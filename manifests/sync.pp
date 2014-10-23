# This class installs a syncronization script for copying an existing
# golden master Antelope installation.
#
# The script uses rsync under the hood, and connects to the source
# system over either rsync:// or SSH. SSH uses the sync_user and
# sync_host variables to compute the ssh credentials
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
# [*ensure*] - if 'present', files are placed on the filesystem. If 'absent',
# files are removed from the filesystem if they were present.
# Default: 'present'
#
# [*sync_host*] - the source hostname for the rsync command
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
class antelope::sync(
  $ensure    = present,
  $sync_user = $antelope::params::sync_user,
  $sync_host = $antelope::params::sync_host,
  $site_tree = $antelope::params::site_tree,
) inherits antelope::params {

  ### Validate variables
  if $ensure == 'present' {
    if !$sync_host { fail('You must specify a value for sync_host.') }
  }

  ### Class local variables

  $basedir   = '/usr/local'

  $manage_file_ensure = $ensure
  $manage_file_owner = 'root'
  $manage_file_group = $::osfamily ? {
    'Solaris' => 'bin',
    'Darwin'  => 'wheel',
    default   => 'root',
  }

  ### The following variables are used in template evaluation
  $confdir   = "${basedir}/etc"
  $bindir    = "${basedir}/bin"
  $rsync_bin = $::osfamily ? {
    'Solaris' => '/opt/csw/bin/rsync',
    default   => '/usr/bin/rsync',
  }
  $sync_dirs = flatten(['/opt/antelope', $site_tree ])

  ### Managed resources

  # Main synchronization script
  file { 'antelope_sync':
    ensure  => $manage_file_ensure,
    path    => "${bindir}/antelope_sync",
    mode    => '0555',
    owner   => $manage_file_owner,
    group   => $manage_file_group,
    content => template('antelope/sync/antelope_sync.erb'),
    require => [
      File[$bindir],
      File['rsync_include'],
      File['rsync_exclude'],
    ],
  }

  # Exclude and include lists
  file { 'rsync_exclude':
    ensure  => $manage_file_ensure,
    path    => "${confdir}/rsync_exclude",
    mode    => '0444',
    owner   => $manage_file_owner,
    group   => $manage_file_group,
    source  => 'puppet:///modules/antelope/sync/rsync_exclude',
    require => File[$confdir],
  }

  file { 'rsync_include':
    ensure  => $manage_file_ensure,
    path    => "${confdir}/rsync_include",
    mode    => '0444',
    owner   => $manage_file_owner,
    group   => $manage_file_group,
    source  => 'puppet:///modules/antelope/sync/rsync_include',
    require => File[$confdir],
  }
}
