# Class: antelope
#
# Manages the Antelope Real-Time Environmental Monitoring suite
# from Boulder Real-Time Technologies
#
# Dependencies:
#  This module is dependent on the following modules:
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
#  *instances* - What real-time systems should be managed as services
#  This parameter can be specified several ways:
#  As a string - This is either a single, or a comma separated list of
#    directories containing real-time systems. An antelope::instance
#    called $service_name is created with the run-time user of $user
#  As an array - list of directories containing real-time systems. An
#    antelope::instance called $service_name is created with the
#    run-time user $user
#  As a hash of hashes - Creates one or more antelope::instance blocks
#    based on the values in the hash. The keys of the outer hash are
#    used as the instance name. Subkeys are any valid parameter to the
#    antelope::instance defined type.
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

  $bool_absent=any2bool($absent)
  $bool_disable=any2bool($disable)
  $bool_disableboot=any2bool($disableboot)
  $bool_audit_only=any2bool($audit_only)

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

  $manage_instance_ensure = $antelope::instances ? {
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

  # We only manage antelope instances if the parameter was provided.
  # This allows antelope::instance declarations in other manifests
  if $antelope::instances {

    # Manage the antelope::instances
    # Behavior varies depending on whether instances is a hash or
    # string/array
    if is_hash($antelope::instances) {
      create_resources('antelope::instance', $antelope::instances)
    } else {
      # single instance
      antelope::instance { $antelope::service_name :
        user   => $antelope::user,
        dirs   => $antelope::instances,
        ensure => $antelope::manage_instance_ensure,
      }
    }
  }

}
