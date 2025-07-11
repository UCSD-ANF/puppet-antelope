# @summary Installs and manages an Antelope real-time system instance
#
# This defined type creates an Antelope service instance with associated
# init scripts and manages permissions for real-time system directories.
#
# @param ensure
#   Whether the service should be present or absent
# @param user
#   Username that the Antelope real-time systems should run as
# @param delay
#   Number of seconds to delay between startups
# @param shutdownwait
#   How long to wait in seconds for real-time system shutdown
# @param subscriptions
#   Array of resources that will cause this instance to stop/restart
# @param servicename
#   Name of the init script (defaults to title)
# @param dirs
#   List of directories containing real-time systems
# @param group
#   Group that Antelope should run as
# @param manage_fact
#   Whether to manage the antelope_services fact
# @param manage_rtsystemdirs
#   Whether to manage permissions in real-time system directories
#
# @example Two real-time systems under user rt
#   antelope::instance { 'antelope':
#     dirs => ['/rtsystems/usarray', '/rtsystems/roadnet'],
#   }
#
# @example Single real-time system with subscriptions
#   antelope::instance { 'antelope-rtida':
#     dirs          => '/rtsystems/ida',
#     user          => 'rtida',
#     subscriptions => [Service['automounter']],
#   }
#
define antelope::instance (
  String                    $servicename = $title,
  Optional[Enum['present', 'absent']] $ensure = undef,
  Optional[Antelope::User]            $user = undef,
  Optional[Integer]                   $delay = undef,
  Optional[Integer]                   $shutdownwait = undef,
  Optional[Array]                     $subscriptions = undef,
  Optional[Antelope::Dirs]            $dirs = undef,
  Optional[Antelope::Group]           $group = undef,
  Optional[Boolean]                   $manage_fact = undef,
  Optional[Boolean]                   $manage_rtsystemdirs = undef,
) {
  include antelope

  # Set parameter defaults from antelope class
  $_ensure = $ensure ? {
    undef   => lookup('antelope::instance_ensure'),
    default => $ensure,
  }
  $_user = $user ? {
    undef   => $antelope::user,
    default => $user,
  }
  $_delay = $delay ? {
    undef   => $antelope::delay,
    default => $delay,
  }
  $_shutdownwait = $shutdownwait ? {
    undef   => $antelope::shutdownwait,
    default => $shutdownwait,
  }
  $_subscriptions = $subscriptions ? {
    undef   => $antelope::instance_subscribe,
    default => $subscriptions,
  }
  $_group = $group ? {
    undef   => $antelope::group,
    default => $group,
  }
  $_manage_fact = $manage_fact ? {
    undef   => $antelope::manage_service_fact,
    default => $manage_fact,
  }
  $_manage_rtsystemdirs = $manage_rtsystemdirs ? {
    undef   => $antelope::manage_rtsystemdirs,
    default => $manage_rtsystemdirs,
  }

  # Sanity test parameters
  if $dirs == undef {
    if ($_ensure == 'present') {
      fail('service enabled but no dirs specified')
    }
  }

  # Set local variables based on the desired state
  # In our management model, we do not ensure the service is running
  $file_ensure    = $_ensure ? { 'present' => 'file', default => $_ensure }
  $link_ensure    = $_ensure ? { 'present' => 'link', default => $_ensure }
  $service_enable = $_ensure ? { 'present' => true  , default => false }

  # Set variables that require the antelope class
  $manage_fact_real = $_manage_fact ? {
    undef   => $antelope::manage_service_fact,
    default => $_manage_fact,
  }

  $manage_rtsystemdirs_real = $_manage_rtsystemdirs ? {
    undef   => $antelope::manage_rtsystemdirs,
    default => $_manage_rtsystemdirs,
  }

  # Determine the path to the init script
  $initfilename = "/etc/init.d/${servicename}"

  # Generate a shutdown reason that we may or may not use later.
  $reason = join([
      "Puppet ${module_name}: pause ${servicename} (per refresh of",
      join($_subscriptions,', '),
      "), using ${initfilename}.",
  ], ' ')
  $stop_reason = shellquote($reason)

  # array of directories that gets evaluated by the template
  if $dirs != undef {
    $real_dirs = $dirs =~ Array ? {
      true  => $dirs,
      false => $dirs.split(','),
    }
  } else {
    $real_dirs = undef
  }

  # Variables for template evaluation
  $osfamily = $facts['os']['family']
  $antelope_latest_perl = pick($facts['antelope_latest_perl'], '5.30')
  $service_title = $servicename

  ### Managed resources

  # Create the rtsystemdir resources
  if ( $real_dirs != undef and $manage_rtsystemdirs_real ) {
    antelope::rtsystemdir { $real_dirs :
      owner => $_user,
      group => $_group,
    }
  }

  # init script path for Linux
  file { $initfilename :
    ensure  => $file_ensure,
    mode    => '0755',
    content => epp('antelope/S99antelope.epp', {
        'osfamily'             => $osfamily,
        'antelope_latest_perl' => $antelope_latest_perl,
        'service_title'        => $service_title,
        'real_dirs'            => $real_dirs,
        'user'                 => $_user,
        'delay'                => $_delay,
        'shutdownwait'         => $_shutdownwait,
    }),
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

  if ($_ensure == 'present') {
    # declare relations based on desired behavior
    File[$initfilename] ~> Service[$servicename]
    User[$_user]         -> Service[$servicename]

    # If we were handed something to "subscribe" to, ensure our
    # new service is off when it is refreshed and on afterward.
    if $_subscriptions != [] {
      exec { "${initfilename} stop":
        command     => "${initfilename} stop ${stop_reason}",
        notify      => $_subscriptions,
        refreshonly => true,
      }
      exec { "${initfilename} start":
        subscribe   => $_subscriptions,
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
