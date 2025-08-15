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
# @param group The group under which this Antelope instance will run. Can be a group name string or numeric GID. If not specified, will use the user's primary group.
define antelope::instance (
  Optional[Antelope::Dirs]  $dirs                               = undef,
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Antelope::User]  $user = undef,
  Optional[Integer]         $delay = undef,
  Optional[Integer]         $shutdownwait = undef,
  Optional[Array]           $subscriptions = undef,
  String                    $servicename = $title,
  Optional[Antelope::Group] $group = undef,
  Optional[Boolean]         $manage_fact = undef,
  Optional[Boolean]         $manage_rtsystemdirs = undef,

) {
  include 'antelope'

  # Use lookup() inside the define body to get defaults from Hiera
  $ensure_real = $ensure
  $user_real = pick($user, lookup('antelope::user'))
  $delay_real = pick($delay, lookup('antelope::delay'))
  $shutdownwait_real = pick($shutdownwait, lookup('antelope::shutdownwait'))
  $subscriptions_real = pick($subscriptions, lookup('antelope::instance_subscribe'))
  $group_real = pick($group, lookup('antelope::group'))

  # Sanity test parameters
  if $dirs == undef {
    if ($ensure == 'present') {
      fail('service enabled but no dirs specified')
    }
  }

  # Set local variables based on the desired state
  # In our management model, we do not ensure the service is running
  $file_ensure    = $ensure ? { 'present' => 'file', default => $ensure }
  $link_ensure    = $ensure ? { 'present' => 'link', default => $ensure }
  $service_enable = $ensure ? { 'present' => true  , default => false }

  # Set variables that require the antelope class
  $manage_fact_real = pick($manage_fact, lookup('antelope::manage_service_fact'))
  $manage_rtsystemdirs_real = pick($manage_rtsystemdirs, lookup('antelope::manage_rtsystemdirs'))

  # Determine the path to the init script
  $initfilename = "/etc/init.d/${servicename}"

  # Generate a shutdown reason that we may or may not use later.
  $reason = join([
      "Puppet ${module_name}: pause ${servicename} (per refresh of",
      join($subscriptions_real,', '),
      "), using ${initfilename}.",
  ], ' ')
  $stop_reason = shellquote($reason)

  # array of directories that gets evaluated by the template
  if $dirs != undef {
    $real_dirs = $dirs =~ Array ? {
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
      owner => $user_real,
      group => $group_real,
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
    provider   => $antelope::service_provider,
  }

  if $manage_fact_real {
    include antelope::service_fact

    concat::fragment { "${antelope::service_fact::file}_${name}":
      target  => $antelope::service_fact::file,
      order   => '20',
      content => "${name}\n",
    }
  }

  if ($ensure == 'present') {
    # declare relations based on desired behavior
    File[$initfilename] ~> Service[$servicename]
    User[$user_real]         -> Service[$servicename]

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
    if $facts['os']['family'] == 'RedHat' {
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
