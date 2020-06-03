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
  String                    $servicename         = $title,
  Enum['present', 'absent'] $ensure              = 'present',
  Optional[Antelope::Dirs]  $dirs                = undef,
  Antelope::User            $user                = 'rt',
  Optional[Antelope::Group] $group               = undef,
  Integer                   $delay               = 0,
  Integer                   $shutdownwait        = 120,
  Optional[Boolean]         $manage_fact         = undef,
  Optional[Boolean]         $manage_rtsystemdirs = undef,
  Array                     $subscriptions       = [],
) {

  include '::antelope'

  # Sanity test parameters
  validate_re($ensure,'^(ab|pre)sent')
  validate_string($user)
  if $group != undef { validate_string($group) }
  validate_string($servicename)
  validate_string($delay)
  validate_array($subscriptions)
  if $manage_fact != undef {
    validate_bool($manage_fact)
  }
  if $manage_rtsystemdirs != undef {
    validate_bool($manage_rtsystemdirs)
  }

  if $dirs == undef {
    if ($ensure == 'present') {
      fail('service enabled but no dirs specified')
    }
  } else {
    unless (is_string($dirs) or is_array($dirs)) {
      fail('dirs must be undef, a string, or an array')
    }
  }

  if ($ensure == 'present' and ! is_integer($delay)) {
    fail('delay parameter must be an integer')
  }


  # Set local variables based on the desired state
  # In our management model, we don't ensure the service is running
  $file_ensure    = $ensure ? { 'present' => 'file', default => $ensure }
  $link_ensure    = $ensure ? { 'present' => 'link', default => $ensure }
  $service_enable = $ensure ? { 'present' => true  , default => false }


  # Set variables that require the antelope class
  $manage_fact_real = $manage_fact ? {
    undef   => $antelope::manage_service_fact,
    default => $manage_fact,
  }

  $manage_rtsystemdirs_real = $manage_rtsystemdirs ? {
    undef   => $antelope::manage_rtsystemdirs,
    default => $manage_rtsystemdirs,
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
  if $dirs != undef {
    $real_dirs = is_array($dirs) ? {
      true  => $dirs,
      false => split($dirs,','),
    }
  } else {
    $real_dirs = undef
  }


  ### Managed resources

  # Create the rtsystemdir resources
  if ( $real_dirs != undef and $manage_rtsystemdirs_real ) {
    antelope::rtsystemdir { $real_dirs :
      owner => $user,
      group => $group,
    }
  }

  # init script path for Linux
  file { $initfilename :
    ensure  => $file_ensure,
    mode    => '0755',
    content => template('antelope/S99antelope.erb'),
  }

  service { $servicename:
    enable     => $service_enable,
    hasrestart => false,
    hasstatus  => false,
    provider   => $::antelope::service_provider,
  }

  if $manage_fact_real {
    include ::antelope::service_fact

    concat::fragment { "${antelope::service_fact::file}_${name}":
      target  => $antelope::service_fact::file,
      order   => '20',
      content => "${name}\n",
    }
  }

  if ($ensure == 'present') {
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
