class antelope::params {

  #$valid_install = ['base','devel']

  ### Application related parameters
  #$install = $::antelope_install ? {
  #  ''      => 'base',                  # Default value
  #  default => $::antelope_install,

   # Make sure we can handle the OS
  if ! ($::osfamily in ['Solaris', 'RedHat']) {
    fail("This module does not yet work on $::operatingsystem")
  } #}

  ### General variables that affect module's behaviour
  # They can be set at top scope level or in a ENC
  $absent = $::antelope_absent ? {
    ''      => false,                   # Default value
    default => $::antelope_absent,
  }

  $disable = $::antelope_disable ? {
    ''      => false,                   # Default value
    default => $::antelope_disable,
  }

  $disableboot = $::antelope_disableboot ? {
    ''      => false,                   # Default value
    default => $::antelope_disableboot,
  }

  ### General module variables that can have a site or per module default
  # They can be set at top scope level or in a ENC

  $debug = $::antelope_debug ? {
    ''      => $::debug ? {
      ''      => false,                # Default value
      default => $::debug,
    },
    default => $::antelope_debug,
  }

  $audit_only = $::antelope_audit_only ? {
    ''      => $::audit_only ? {
      ''      => false,                # Default value
      default => $::audit_only,
    },
    default => $::antelope_audit_only,
  }

  $rtsystems = $::antelope_rtsystems ? {
    ''      => undef,                  # Default value
    default => $::antelope_rtsystems,
  }

  $service_name = $::antelope_service_name ? {
    ''      => 'antelope',             # Default value
    default => $::antelope_service_name,
  }
}
