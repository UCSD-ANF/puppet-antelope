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
# Although nothing is autorequired directly from this class, if 'dirs'
# or 'instances' are provided, the antelope::instance defined
# type will autorequire several resources, including a User and the
# directories passed to it
#
# Dependencies:
#
#  This module is dependent on the following modules:
#
#  * puppetlabs-stdlib as stdlib
#  * example42-puppi as puppi
#  * For puppet 2.6, puppetlabs-create_resources. 2.7 ships with that
#  function in core
#
# Parameters:
#  *absent* - make sure that Antelope is not installed
#
#  *debug* - Turn on some debugging options
#
#  *disable* - Don't start up any services. Removes init scripts
#
#  *disableboot* - installs init scripts but set's them to not start at
#   boot
#
#  *audit_only* - makes no changes to the system, just tracks changes
#
#  *dirs* - Directories to manage as Antelope rtsystems.
#  *Must be used exclusive of instances parameter.* This parameter can
#  be specified several ways:
#  As a string - This is either a single, or a comma separated list of
#    directories containing real-time systems. An antelope::instance
#    called $service_name is created with the run-time user of $user
#  As an array - list of directories containing real-time systems. An
#    antelope::instance called $service_name is created with the
#    run-time user $user
#
#  *instances* - Creates one or more antelope::instance blocks
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
#        user => 'rt2',
#        dirs => [ 'foo', 'bar', 'baz' ],
#      }
#    }
#
class antelope (
  $absent = $antelope::params::absent,
  $debug = $antelope::params::debug,
  $disable = $antelope::params::disable,
  $disableboot = $antelope::params::disableboot,
  $audit_only = $antelope::params::audit_only,
  $dirs = $antelope::params::dirs,
  $instances = $antelope::params::instances,
  $version = $antelope::params::version,
  $user = $antelope::params::user,
  $service_name = $antelope::params::service_name
) inherits antelope::params{

  include 'stdlib'

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
  if ( $antelope::dirs and $antelope::instances ) {
    fail("Can't specify both dirs and instances.")
  }

  if ( $antelope::instances ) {
    validate_hash($antelope::instances)
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

  $manage_package = $antelope::bool_absent ? {
    true  => 'absent',
    false => 'present',
  }

  $manage_service_enable = $antelope::bool_disableboot ? {
    true    => false,
    default => $antelope::bool_disable ? {
      true    => false,
      default => $antelope::bool_absent ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_ensure = $antelope::bool_disable ? {
    true    => 'stopped',
    default =>  $antelope::bool_absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  # We only manage the singleton Antelope::Instance if dirs is defined
  # or disable/absent is true
  $manage_singleton_instance = $antelope::dirs ? {
    '' => $antelope::bool_disable ? {
      true    => true,
      default => $antelope::bool_absent,
    },
    default => true,
  }

  # We only manage the multiple instances if instances is defined.
  # Since we can't enumerate any pre-existing Antelope::Instances that
  # aren't named with the default service_name, we won't try to clean
  # them up.
  $manage_plural_instances = $antelope::instances

  $manage_instance_ensure = $antelope::dirs ? {
    ''      => 'absent',
    default => $antelope::bool_disable ? {
      false => 'present',
      true  => 'absent',
    },
  }

  $manage_file = $antelope::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $antelope::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $antelope::bool_audit_only ? {
    true  => false,
    false => true,
  }

  ### Managed resources
  # We call the required subclass based on the install type
  #include "antelope::$install"

  # We manage antelope instances only if the 'instances' or 'dirs'
  # parameters were provided.
  if $antelope::manage_plural_instances {
    create_resources('antelope::instance', $antelope::instances)
  }

  if $antelope::manage_singleton_instance {
    antelope::instance { $antelope::service_name :
      user   => $antelope::user,
      dirs   => $antelope::dirs,
      ensure => $antelope::manage_instance_ensure,
    }
  }

}
