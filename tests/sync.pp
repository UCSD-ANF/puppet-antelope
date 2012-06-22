### Set up some defaults for the Antelope module
$antelope_site_tree = '/opt/anf'
$antelope_sync_host = $::osfamily ? {
  'RedHat'  => 'anfbuildl.ucsd.edu',
  'Solaris' => 'anfbuilds.ucsd.edu',
  'Darwin'  => 'anfbuildm.ucsd.edu',
}
$antelope_sync_user = 'rt'

file { ['/usr/local/bin','/usr/local/etc'] :
  ensure => directory,
}

include antelope::sync
