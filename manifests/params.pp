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

  $dirs = $::antelope_dirs ? {
    ''      => undef,                  # Default value
    default => $::antelope_dirs,
  }

  $instances = $::antelope_instances ? {
    ''      => undef,                  # Default value
    default => $::antelope_instances,
  }

  $service_name = $::antelope_service_name ? {
    ''      => 'antelope',             # Default value
    default => $::antelope_service_name,
  }

  $user = $::antelope_user ? {
    ''      => 'rt',
    default => $::antelope_user,
  }

  ### Directory containing facts for the facts.d plugin (part of stdlib)
  # Look for antelope_facts_dir, then for facts_dir in top scope
  $facts_dir = $::antelope_facts_dir ? {
    '' => $::facts_dir ? {
      ''      => '/etc/facter/facts.d', # Default value
      default => $::facts_dir,
    },
    default => $::antelope_facts_dir,
  }

  ### Controls whether or not we manage the antelope_instance fact
  # if true, requires the 'concat' module
  $manage_service_fact = $::antelope_manage_service_fact ? {
    ''      => true,                   # Default value
    default => $::antelope_manage_service_fact,
  }

  ### Controls how long we wait for a system to shut down cleanly
  $shutdownwait = $::antelope_shutdownwait ? {
    ''      => 120,
    default => $::antelope_shutdownwait,
  }

  ### Host containing golden copy of Antelope for sync script
  $sync_host = $::antelope_sync_host ? {
    '' => $::osfamily ? {
      'RedHat'  => 'anfbuildl.ucsd.edu',
      'Solaris' => 'anfbuilds.ucsd.edu',
    },
    default => $::antelope_sync_host,
  }

  ### Source username for Antelope sync script
  $sync_user = $::antelope_sync_user ? {
    ''      => 'rt',
    default => $::antleope_sync_user,
  }

}
