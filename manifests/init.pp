class antelope (
  $absent = $antelope::params::absent,
  $debug = $antelope::params::debug,
  $disable = $antelope::params::disable,
  $disableboot = $antelope::params::disableboot,
  $audit_only = $antelope::params::audit_only
) inherits antelope::params{
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
}
