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
define antelope::rtsystemdir(
  Antelope::User  $owner = lookup('antelope::user'),
  Antelope::Group $group = lookup('antelope::group'),
  String          $dir_mode = lookup('antelope::rtsystem_dir_mode'),
  String          $rtexec_mode = lookup('antelope::rtsystem_rtexec_mode'),
  String          $path = $title,
) {
  include '::antelope'

  $manage_file_owner = $owner
  $manage_file_group = $group
  $manage_file_ensure = 'present'

  $manage_rtexec_mode     = $rtexec_mode
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
