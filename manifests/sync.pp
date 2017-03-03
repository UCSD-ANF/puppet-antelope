# This class installs a syncronization script for copying an existing
# golden master Antelope installation.
#
# The script uses rsync under the hood, and connects to the source
# system over either rsync:// or SSH. SSH uses the user and
# host variables to compute the ssh credentials
#
# It depends on passwordless SSH being set up. It also needs a working
# copy of rsync installed in /usr/bin on Linux and Darwin
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
# [*host*] - the source hostname for the rsync command
# Can also be specified by the global variable
# $::antelope_sync_host
# This parameter can either be a bare hostname, or optionally include the
# prefex rsync:// in which case it will use the native rsync protocol instead
# of rsync over ssh.
# Examples:
# * 'rsync://build.test.domain'
# * 'build.test.domain'
#
# [*user*] - the source username for the rsync command
# Can also be specified by the global variables $::antelope_sync_user
# or $::antelope_user. Defaults to 'rt'
#
# [*site_tree*] - optional site-local Antelope tree to synchronize.
# Defaults to undef. Example value is /opt/anf
# Can also be specified with the global variable $::antelope_site_tree
#
class antelope::sync(
  $ensure    = present,
  $host      = undef, # must be set if ensure is present
  $user      = 'rt',
  $site_tree = undef,
  $basedir   = '/usr/local',
  $rsync_bin = '/usr/bin/rsync',
) {

  include ::antelope

  ### Validate variables
  validate_re($ensure, '^(pre|ab)sent$')

  if $ensure == 'present' {
    if !$host { fail('You must specify a value for host.') }
  }

  ### Class local variables

  $manage_file_ensure = $ensure
  $manage_file_owner = 'root'
  $manage_file_group = $::osfamily ? {
    'Darwin'  => 'wheel',
    default   => 'root',
  }

  ### The following variables are used in template evaluation
  $confdir   = "${basedir}/etc"
  $bindir    = "${basedir}/bin"
  $sync_dirs = flatten(['/opt/antelope', $site_tree ])
  $sync_host = $host
  $sync_user = $user


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
