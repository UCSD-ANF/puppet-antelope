# Class: antelope
#
# Manages the Antelope Real-Time Environmental Monitoring suite
# from Boulder Real-Time Technologies

# Description:
#
# This class is designed to be used as a singleton instance. If the
# 'dirs' or 'instances' parameter is provided, it automatically manages
# one or more antelope::instance resource types.
#
# Autorequires:
#
# Although nothing is autorequired directly from this class, some
# resources will be required if the 'dirs' or 'instances' parameters
# are not null. In particular, the antelope::instance defined
# type will autorequire several resources, including:
# * the user that the antelope instance is to run as
# * the directories that contain the real-time systems
# * the directory that the antelope_services fact should be installed
#   into, if the manage_service_fact parameter is set to true on this
#   class, or if the manage_fact parameter is set to true on any
#   declaration of antelope::instance
#
# Dependencies:
#
#  This module is dependent on the following modules:
#
#  * puppetlabs-stdlib as stdlib
#  * For puppet 2.6, puppetlabs-create_resources. 2.7 ships with that
#  function in core
#  * puppetlabs/concat if $instance_fact is true
#
# Parameters:
#  [*absent*] - make sure that Antelope is not installed
#
#  [*debug*] - Turn on some debugging options
#
#  [*disable*] - Don't start up any services. Removes init scripts
#
#  [*disableboot*] - installs init scripts but set's them to not start
#   at boot
#
#  [*audit_only*] - makes no changes to the system, just tracks changes
#
#  [*dirs*] - Directories to manage as Antelope rtsystems.
#  *Must be used exclusive of instances parameter.* This parameter can
#  be specified several ways:
#  As a string - This is either a single, or a comma separated list of
#    directories containing real-time systems. An antelope::instance
#    called $service_name is created with the run-time user of $user
#  As an array - list of directories containing real-time systems. An
#    antelope::instance called $service_name is created with the
#    run-time user $user
#
#  [*instances*] - Creates one or more antelope::instance blocks
#  *Must be used exclusive of dirs parameter.*
#  This parameter should be provided as a hash of hashes. The keys of
#    the outer hash are used as the instance name. Subkeys are any
#    valid parameter to the antelope::instance defined type.
#    Format:
#    {
#      'servicename' => {
#        user => 'rt',
#        dirs => 'dirname' ,
#      }
#      'anotherservicename' = {
#        user        => 'rt2',
#        dirs        => [ 'foo', 'bar', 'baz' ],
#        manage_fact => false,
#      }
#    }
#
#  [*instance_subscribe*] - Used to work around the sometime fragile
#  Antelope service.  If $instances is set, expects an array of
#  items that will pause the Antelope service before and restart the
#  Antelope service before the item(s) are refreshed. Affects all
#  instances, unless specifically overidden in the $instances hash.
#    Format:
#    [
#      Service['automounter'],
#      Exec['/usr/local/bin/antelope_sync'],
#    ]
#
#  [*manage_service_fact*] - if true, creates a fact in the facter
#  facts.d directory (specified by the parameter $facts_dir) called
#  antelope_services. This fact will contain a comma separated list
#  of antelope::instance names. Defaults to true.
#
#  [*service_provider*]
#  Override the default service provider. Default is 'redhat' on EL7 systems,
#  and undef on other systems
#
#  [*facts_dir*] - path to the facts.d directory that is parsed by
#  facter for externally provided facts. Defaults to
#  "/etc/facter/facts.d". On Puppet Enterprise, it may make more sense
#  to use /etc/puppetlabs/facter/facts.d. Note that this directory is
#  auto-required if manage_service_fact is true.
#
#  [*delay*]
#  Number of seconds to delay between startups. Default value of 0 means no
#  delay.
#
#  [*shutdownwait*] - controls the Antelope init script timeout for how
#  long it will wait before it forcibly kills an rtexec process. Only
#  has an effect when the dirs parameter is used. Otherwise, the
#  shutdown wait should be specified inside of the instances hash.
#
#  [*dist_owner*] - user that should own files in the $ANTELOPE tree.
#  Defaults to 'root'
#
#  [*dist_group*] - group that should own files in the $ANTELOPE tree.
#  Defaults are os-specific, 'wheel' on Darwin and 'root' on Linux
#
#  [*dist_mode*] - file mode for files in the $ANTELOPE tree. Default is 0644
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
  Antelope::Version             $version = $facts['antelope_latest_version'],
  Optional[String]              $service_provider,
  Optional[Antelope::Dirs]      $dirs,
  Optional[Antelope::Instances] $instances,
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
    default =>  $absent ? {
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

  validate_bool($manage_plural_instances)

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
      }
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
    notice('Neither managing a singleton nor plural instance of Antelope.')
  }

}
