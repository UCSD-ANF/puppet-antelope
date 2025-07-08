# @summary Installs a synchronization script for copying Antelope installations
#
# This class creates an rsync-based synchronization script for copying an
# existing golden master Antelope installation. The script supports both
# rsync:// protocol and rsync over SSH.
#
# @param ensure
#   Whether files should be present or absent on the filesystem
# @param user
#   Username for the rsync command (source system)
# @param owner
#   Local file owner for created files
# @param group
#   Local file group for created files
# @param exec_mode
#   File mode for executable files
# @param data_mode
#   File mode for data files
# @param basedir
#   Base directory for installing sync scripts
# @param rsync_bin
#   Path to the rsync binary
# @param site_tree
#   Optional site-local Antelope tree to synchronize
# @param host
#   Source hostname for rsync (required when ensure is present)
#
# @example Basic synchronization setup
#   class { 'antelope::sync':
#     host => 'build.example.com',
#   }
#
# @example With site-specific tree
#   class { 'antelope::sync':
#     host      => 'rsync://build.example.com',
#     site_tree => '/opt/anf',
#   }
#
class antelope::sync (
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
  include antelope

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
  $sync_dirs = ['/opt/antelope', $site_tree].flatten()
  $sync_host = $host
  $sync_user = $user
  $antelope_services = pick($facts['antelope_services'], '')

  ### Managed resources

  # Main synchronization script
  file { 'antelope_sync':
    ensure  => $manage_file_ensure,
    path    => "${bindir}/antelope_sync",
    mode    => $manage_file_exec_mode,
    owner   => $manage_file_owner,
    group   => $manage_file_group,
    content => epp('antelope/sync/antelope_sync.epp', {
      'confdir'           => $confdir,
      'bindir'            => $bindir,
      'sync_dirs'         => $sync_dirs,
      'sync_host'         => $sync_host,
      'sync_user'         => $sync_user,
      'antelope_services' => $antelope_services,
      'rsync_bin'         => $rsync_bin,
    }),
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
