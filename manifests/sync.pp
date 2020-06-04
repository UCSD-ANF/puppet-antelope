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
  Enum['present', 'absent']    $ensure,
  Antelope::User               $user,
  Antelope::User               $owner,
  Antelope::Group              $group,
  String                       $exec_mode,
  String                       $data_mode,
  Stdlib::Absolutepath         $basedir,
  Stdlib::Absolutepath         $rsync_bin,
  Optional[String]             $site_tree = undef,
  Optional[Antelope::Synchost] $host      = undef, # must be set if ensure is present
) {
  include ::antelope

  ### Validate variables

  if $ensure == 'present' {
    if !$host { fail('You must specify a value for host.') }
  }

  ### Class local variables

  $manage_file_ensure = $ensure
  $manage_file_owner = $owner
  $manage_file_group = $group
  $manage_file_exec_mode = $exec_mode
  $manage_file_data_mode = $data_mode

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
    mode    => $manage_file_exec_mode,
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
  file {
    'rsync_exclude':
      path   => "${confdir}/rsync_exclude",
      source => 'puppet:///modules/antelope/sync/rsync_exclude',
    ;
    'rsync_include':
      path   => "${confdir}/rsync_include",
      source => 'puppet:///modules/antelope/sync/rsync_include',
    ;
    default:
      ensure  => $manage_file_ensure,
      mode    => $manage_file_data_mode,
      owner   => $manage_file_owner,
      group   => $manage_file_group,
      require => File[$confdir],
  }
}
