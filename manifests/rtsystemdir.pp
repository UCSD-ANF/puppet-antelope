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
# [*user*]
#  The username that the real-time system should run as. Defaults to 'rt'
define antelope::rtsystemdir(
  $path        = $title,
  $owner       = 'rt',
  $group       = undef,
  $dir_mode    = 0775,
  $rtexec_mode = 0664,
) {
  require antelope::params

  $manage_file_user       = $user
  $manage_file_group      = $group
  $manage_file_ensure     = 'present'

  $manage_rtexec_mode     = $rtexec_mode
  $manage_rtexec_filename = "${path}/rtexec.pf"
  $manage_rtexec_replace  = false

  file { $manage_rtexec_filename :
    ensure  => $manage_file_ensure,
    owner   => $manage_file_user,
    group   => $manage_file_group,
    mode    => $manage_rtexec_mode,
    replace => $manage_rtexec_replace,
  }
}
