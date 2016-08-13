# instance.pp
#
# Install an Antelope init script and optionally manage permissions on key
# parameter files for a list of real-time systems
#
# == Parameters
#
# [*servicename*]
#   The name of the init resource name, after /etc/init.d. Typically set to
# "antelope". Defaults to the value of title - this is the namevar
#
# [*dirs*]
#   List of directories containing real-time systems.
# e.g. "/export/home/rt/dirs/usarray"
#
# [*user*]
#   The username that the Antelope real-time systems should run as. Defaults
#  to 'rt'.
#
# [*delay*]
#   Number of seconds to delay between startups. Default value of 0 means no
# delay.
#
# [*ensure*]
#   Controls whether the service should be there or not
#
# [*shutdownwait*]
#   How long to wait in seconds for a real-time system to shutdown. Defaults
#   to 120 seconds.
#
# [*manage_fact*]
#   If false, does not manage the facter fact antelope_instances.
#   Defaults to true
#
# [*manage_rtsystemdirs*]
#   If true, will manage permissions inside each directory specified in *dirs*
#
# [*subscriptions*]
#   If set, this Antelope instance will be stopped and restarted
#   Defaults to undef
#
#
# == Autorequires
# This resource auto-requires the following resources:
#  User[$user]
#
# == Examples
#
# Two real-time systems running under user rt
#    antelope::instance{
#      'antelope':
#        dirs => [ '/export/home/rt/dirs/usarray',
#                      '/export/home/rt/dirs/roadnet', ],
#    }
#
# A single real-time system running under user rtida
# that pauses its service when either the automounter or yum update.
#    antelope::instance {
#      'antelope-rtida':
#        dirs          => '/export/home/rtida/dirs/ida',
#        user          => 'rt',
#        subscriptions => [
#          Service['automounter'],
#          Exec['yum -y upgrade'],
#        ],
#    }
#
define antelope::instance(
  $servicename         = $title,
  $ensure              = 'present',
  $dirs                = undef,
  $user                = 'rt',
  $group               = undef,
  $delay               = '0',
  $shutdownwait        = '120',
  $manage_fact         = '', # lint:ignore:empty_string_assignment
  $manage_rtsystemdirs = '', # lint:ignore:empty_string_assignment
  $subscriptions       = [],
) {
  require antelope::params

  # We don't (yet) support Darwin.
  validate_re($::osfamily,'^(RedHat|Solaris)$',
    "Unsupported for ${::operatingsystem}.")

  # Sanity test parameters
  validate_re($ensure,'^(ab|pre)sent')
  validate_string($user)
  if $group != undef { validate_string($group) }
  validate_string($servicename)
  validate_string($delay)
  validate_array($subscriptions)

  # Set local variables based on the desired state
  # In our management model, we don't ensure the service is running
  $file_ensure    = $ensure ? { 'present' => 'file', default => $ensure }
  $link_ensure    = $ensure ? { 'present' => 'link', default => $ensure }
  $service_enable = $ensure ? { 'present' => true  , default => false }

  $bool_manage_fact = $manage_fact ? {
    true    => $manage_fact,
    false   => $manage_fact,
    ''      => $antelope::params::manage_service_fact,
    default => str2bool($manage_fact),
  }

  $bool_manage_rtsystemdirs = $manage_rtsystemdirs ? {
    true    => $manage_rtsystemdirs,
    false   => $manage_rtsystemdirs,
    ''      => $antelope::params::manage_rtsystemdirs,
    default => str2bool($manage_rtsystemdirs),
  }

  # Determine the path to the init script
  $initfilename = "/etc/init.d/${servicename}"

  # Generate a shutdown reason that we may or may not use later.
  $reason = join([
    "Puppet ${module_name}: pause ${servicename} (per refresh of",
    join($subscriptions,', '),
    "), using ${initfilename}.",
  ], ' ')
  $stop_reason = shellquote($reason)

  # array of directories that gets evaluated by the template
  $real_dirs = is_array($dirs) ? {
    true  => $dirs,
    false => split($dirs,','),
  }


  ### Managed resources

  # Create the rtsystemdir resources
  if $bool_manage_rtsystemdirs {
    antelope::rtsystemdir { $real_dirs :
      owner => $user,
      group => $group,
    }
  }

  # init script path for Solaris and Linux
  file { $initfilename :
    ensure  => $file_ensure,
    mode    => '0755',
    content => template('antelope/S99antelope.erb'),
  }

  service { $servicename:
    enable     => $service_enable,
    hasrestart => false,
    hasstatus  => false,
  }

  # On Solaris we don't use SMF. We provide a bare init script which
  # requires manual creation of symlinks.
  if $::osfamily == 'Solaris' {
    Service[$servicename] { provider => 'init' }
    # Create/remove symlinks
    file { [
      "/etc/rc0.d/K01${servicename}",
      "/etc/rc1.d/K01${servicename}",
      "/etc/rc3.d/S99${servicename}",
    ]:
      ensure  => $link_ensure,
      target  => $initfilename,
      require => File[$initfilename],
    }
  }

  if $bool_manage_fact {
    include antelope::service_fact

    concat::fragment { "${antelope::service_fact::file}_${name}":
      ensure  => $ensure,
      target  => $antelope::service_fact::file,
      order   => '20',
      content => "${name}\n",
    }
  }

  if ($ensure == 'present') {
    # More sanity checks.
    if $dirs == undef       { fail('service enabled but no dirs specified') }
    if ! is_integer($delay) { fail('delay parameter must be an integer') }

    # declare relations based on desired behavior
    File[$initfilename] ~> Service[$servicename]
    User[$user]         -> Service[$servicename]

    # If we were handed something to "subscribe" to, ensure our
    # new service is off when it is refreshed and on afterward.
    if !empty($subscriptions) {
      exec { "${initfilename} stop":
        command     => "${initfilename} stop ${stop_reason}",
        notify      => $subscriptions,
        refreshonly => true,
      }
      exec { "${initfilename} start":
        subscribe   => $subscriptions,
        refreshonly => true,
      }
    }
    if $::osfamily == 'RedHat' {
      # chkconfig is kinda dumb, try to force it to do the right thing
      exec { "chkconfig ${servicename} reset":
        path        => '/sbin',
        refreshonly => true,
        subscribe   => File[$initfilename],
      }
    }
  } else {
    # declare relations based on desired behavior
    Service[$servicename] -> File[$initfilename]
  }
}
