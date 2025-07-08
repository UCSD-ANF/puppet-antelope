# @summary Manages the Antelope Real-Time Environmental Monitoring suite
#
# This class manages Antelope Real-Time Environmental Monitoring software
# from Boulder Real-Time Technologies. It supports Antelope versions 5.9
# through 5.15 on modern operating systems.
#
# @param absent
#   Ensure Antelope is not installed when true
# @param debug
#   Enable debugging options
# @param disable
#   Don't start services and remove init scripts
# @param disableboot
#   Install init scripts but disable them at boot
# @param audit_only
#   Make no changes to the system, only track changes
# @param instance_subscribe
#   Array of resources that will cause Antelope service restart
# @param user
#   Username that Antelope real-time systems should run as
# @param group
#   Group that Antelope should run as
# @param service_name
#   Name of the Antelope service
# @param manage_service_fact
#   Create antelope_services fact when true
# @param manage_rtsystemdirs
#   Manage permissions in real-time system directories
# @param facts_dir
#   Path to facter facts.d directory
# @param delay
#   Seconds to delay between service startups
# @param shutdownwait
#   Timeout in seconds for service shutdown
# @param dist_owner
#   User that should own files in ANTELOPE tree
# @param dist_group
#   Group that should own files in ANTELOPE tree
# @param dist_mode
#   File mode for files in ANTELOPE tree
# @param version
#   Antelope version to use (defaults to latest detected)
# @param service_provider
#   Override default service provider (systemd/redhat)
# @param dirs
#   Directories to manage as Antelope real-time systems.
#   Mutually exclusive with instances parameter.
# @param instances
#   Hash of antelope::instance resources to create.
#   Mutually exclusive with dirs parameter.
#
# @example Basic usage
#   include antelope
#
# @example With real-time system directories
#   class { 'antelope':
#     dirs => ['/rtsystems/usarray', '/rtsystems/ci'],
#   }
#
# @example Multiple instances
#   class { 'antelope':
#     instances => {
#       'antelope-primary' => {
#         user => 'rt',
#         dirs => '/rtsystems/primary',
#       },
#       'antelope-backup' => {
#         user => 'rtbackup',
#         dirs => '/rtsystems/backup',
#       },
#     },
#   }
#
class antelope (
  Boolean                       $absent,
  Boolean                       $debug,
  Boolean                       $disable,
  Boolean                       $disableboot,
  Boolean                       $audit_only,
  Array                         $instance_subscribe,
  Antelope::User                $user,
  Antelope::Group               $group,
  String                        $service_name,
  Boolean                       $manage_service_fact,
  Boolean                       $manage_rtsystemdirs,
  Stdlib::Absolutepath          $facts_dir,
  Integer                       $delay,
  Integer                       $shutdownwait,
  Antelope::User                $dist_owner,
  Antelope::Group               $dist_group,
  String                        $dist_mode,
  Optional[String]              $service_provider = undef,
  Optional[Antelope::Dirs]      $dirs = undef,
  Optional[Antelope::Instances] $instances = undef,
  Antelope::Version             $version = $facts['antelope_latest_version'],
) {
  ### Sanity check

  # verify that dirs and instances weren't both specified
  if ( $dirs != undef and $instances != undef ) {
    fail('Cannot specify both dirs and instances.')
  }

  $manage_package = $absent ? {
    true  => 'absent',
    false => 'present',
  }

  $manage_service_enable = $disableboot ? {
    true    => false,
    default => $disable ? {
      true    => false,
      default => !$absent,
    },
  }

  $manage_service_ensure = $disable ? {
    true    => 'stopped',
    default => $absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  # We only manage the singleton Antelope::Instance if dirs is defined
  # or disable/absent is true
  $manage_singleton_instance = $dirs ? {
    undef     => $disable ? {
      true    => true,
      default => $absent,
    },
    ''        => $disable ? {
      true    => true,
      default => $absent,
    },
    default => true,
  }

  # We only manage the multiple instances if instances is defined.
  # Since we can't enumerate any pre-existing Antelope::Instances that
  # aren't named with the default service_name, we won't try to clean
  # them up.
  $manage_plural_instances = $instances ? {
    undef   => false,
    default => true,
  }

  $manage_instance_ensure = $dirs ? {
    ''      => 'absent',
    undef   => 'absent',
    default => $disable ? {
      false => 'present',
      true  => 'absent',
    },
  }

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = !$audit_only

  # Set up resource hashes.
  if $manage_plural_instances {
    $instances_real = $instances
  } elsif $manage_singleton_instance {
    $instances_real = {
      "${service_name}" => {
        dirs   => $dirs,
        ensure => $manage_instance_ensure,
      },
    }
  } else {
    $instances_real = undef
  }

  $instance_defaults = {
    subscriptions       => $instance_subscribe,
    user                => $user,
    group               => $group,
    manage_fact         => $manage_service_fact,
    manage_rtsystemdirs => $manage_rtsystemdirs,
    shutdownwait        => $shutdownwait,
    delay               => $delay,
  }

  ### Managed resources
  # We call the required subclass based on the install type
  #include "antelope::$install"

  # We manage antelope instances only if the 'instances' or 'dirs'
  # parameters were provided.
  if $instances_real != undef {
    #create_resources('antelope::instance', $instances_real, $instance_defaults )
    $instances_real.each |String $index, Hash $value| {
      antelope::instance {
        $index :
          * => $value;
        default :
          * => $instance_defaults;
      }
    }
  } else {
    notify { 'antelope_no_instances':
      message => 'Neither managing a singleton nor plural instance of Antelope.',
    }
  }
}
