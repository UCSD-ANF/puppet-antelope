# rtsystemdir.pp
#
# Manage permissions inside the Antelope real-time system specified by $path
#
# == Parameters
#
# [*path*]
#   The path to the real-time system directory. Typically set to something like
# "/export/home/rt/rtsystems/foo". Defaults to the value of title - this is
# the *namevar*
#
# [*owner*]
#  The ownername that the real-time system should run as. Defaults to 'rt'
# @param group The group that should own the real-time system directory. Can be a group name string or numeric GID.
# @param dir_mode The file permissions for the real-time system directory. Defaults to lookup value.
# @param rtexec_mode The file permissions for the rtexec executable within the directory. Defaults to lookup value with setgid.
define antelope::rtsystemdir (
  Optional[Antelope::User]  $owner = undef,
  Optional[Antelope::Group] $group = undef,
  Optional[String]          $dir_mode = undef,
  Optional[String]          $rtexec_mode = undef,
  String                    $path = $title,
) {
  include 'antelope'

  # Use lookup() inside the define body to get defaults from Hiera
  $owner_real = pick($owner, lookup('antelope::user'))
  $group_real = pick($group, lookup('antelope::group'))
  $dir_mode_real = pick($dir_mode, lookup('antelope::rtsystem_dir_mode'))
  $rtexec_mode_real = pick($rtexec_mode, lookup('antelope::rtsystem_rtexec_mode'))

  $manage_file_owner = $owner_real
  $manage_file_group = $group_real
  $manage_file_ensure = 'present'

  $manage_rtexec_mode     = $rtexec_mode_real
  $manage_rtexec_filename = "${path}/rtexec.pf"
  $manage_rtexec_replace  = false

  file { $manage_rtexec_filename :
    ensure  => $manage_file_ensure,
    owner   => $manage_file_owner,
    group   => $manage_file_group,
    mode    => $manage_rtexec_mode,
    replace => $manage_rtexec_replace,
  }
}
