# @summary Manages permissions inside an Antelope real-time system directory
#
# This defined type manages permissions for files and directories within
# an Antelope real-time system directory, specifically focusing on the
# rtexec.pf file permissions.
#
# @param owner
#   The username that the real-time system should run as
# @param group
#   The group that the real-time system should run as
# @param dir_mode
#   File mode for directories in the real-time system
# @param rtexec_mode
#   File mode for the rtexec.pf file
# @param path
#   The path to the real-time system directory (defaults to title)
#
# @example Manage permissions for a real-time system
#   antelope::rtsystemdir { '/export/home/rt/rtsystems/foo':
#     owner => 'rt',
#     group => 'rt',
#   }
#
define antelope::rtsystemdir (
  Antelope::User  $owner = lookup('antelope::user'),
  Antelope::Group $group = lookup('antelope::group'),
  String          $dir_mode = lookup('antelope::rtsystem_dir_mode'),
  String          $rtexec_mode = lookup('antelope::rtsystem_rtexec_mode'),
  String          $path = $title,
) {
  include antelope

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
