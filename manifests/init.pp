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
#  [*facts_dir*] - path to the facts.d directory that is parsed by
#  facter for externally provided facts. Defaults to
#  "/etc/facter/facts.d". On Puppet Enterprise, it may make more sense
#  to use /etc/puppetlabs/facter/facts.d. Note that this directory is
#  auto-required if manage_service_fact is true.
#
#  [*shutdownwait*] - controls the Antelope init script timeout for how
#  long it will wait before it forcibly kills an rtexec process. Only
#  has an effect when the dirs parameter is used. Otherwise, the
#  shutdown wait should be specified inside of the instances hash.
#
class antelope (
  $absent               = $antelope::params::absent,
  $debug                = $antelope::params::debug,
  $disable              = $antelope::params::disable,
  $disableboot          = $antelope::params::disableboot,
  $audit_only           = $antelope::params::audit_only,
  $dirs                 = $antelope::params::dirs,
  $instances            = $antelope::params::instances,
  $instance_subscribe   = $antelope::params::instance_subscribe,
  $version              = $antelope::params::version,
  $user                 = $antelope::params::user,
  $service_name         = $antelope::params::service_name,
  $manage_service_fact  = $antelope::params::manage_service_fact,
  $facts_dir            = $antelope::params::facts_dir,
  $shutdownwait         = $antelope::params::shutdownwait
) inherits antelope::params {

  include stdlib

  # TODO: rework install to actually install Antelope, rather than
  # fiddle with packages and mountpoints. For the time being, the whole
  # mess is disabled
  #  $install = $antelope::params::install,

  ### Sanity check

  # verify install is valid:
  #if ! member($antelope::params::valid_install, $install) {
  #  fail("value \"$install\" of parameter install is not valid")
  #}

  # verify that dirs and instances weren't both specified
  if ( $dirs and $instances ) {
    fail('Cannot specify both dirs and instances.')
  }

  if ( $instances ) {
    validate_hash($instances)
    validate_array($instance_subscribe)
  }

  $bool_absent=is_string($absent) ? {
    false => $absent,
    true  => str2bool($absent),
  }
  $bool_disable=is_string($disable) ? {
    false   => $disable,
    default => str2bool($disable),
  }
  $bool_disableboot=is_string($disableboot) ? {
    false   => $disableboot,
    default => str2bool($disableboot),
  }
  $bool_audit_only=is_string($audit_only) ? {
    false   => $audit_only,
    default => str2bool($audit_only),
  }

  $manage_package = $bool_absent ? {
    true  => 'absent',
    false => 'present',
  }

  $manage_service_enable = $bool_disableboot ? {
    true    => false,
    default => $bool_disable ? {
      true    => false,
      default => $bool_absent ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_ensure = $bool_disable ? {
    true    => 'stopped',
    default =>  $bool_absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  # We only manage the singleton Antelope::Instance if dirs is defined
  # or disable/absent is true
  $manage_singleton_instance = $dirs ? {
    '' => $bool_disable ? {
      true    => true,
      default => $bool_absent,
    },
    default => true,
  }

  # We only manage the multiple instances if instances is defined.
  # Since we can't enumerate any pre-existing Antelope::Instances that
  # aren't named with the default service_name, we won't try to clean
  # them up.
  $manage_plural_instances = $instances

  $manage_instance_ensure = $dirs ? {
    ''      => 'absent',
    default => $bool_disable ? {
      false => 'present',
      true  => 'absent',
    },
  }

  $manage_file = $bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $bool_audit_only ? {
    true  => false,
    false => true,
  }

  ### Managed resources
  # We call the required subclass based on the install type
  #include "antelope::$install"

  # We manage antelope instances only if the 'instances' or 'dirs'
  # parameters were provided.
  if $manage_plural_instances {
    $instance_defaults = { subscriptions => $instance_subscribe }
    create_resources('antelope::instance', $instances, $instance_defaults)

  } elsif $manage_singleton_instance {
    antelope::instance { $service_name :
      ensure        => $manage_instance_ensure,
      user          => $user,
      dirs          => $dirs,
      manage_fact   => $manage_service_fact,
      shutdownwait  => $shutdownwait,
      subscriptions => $instance_subscribe,
    }
  } else {
    notice('Not managing a singleton nor plural instance of Antelope.')
  }
}
