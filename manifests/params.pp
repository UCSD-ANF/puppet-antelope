# Parameters for the antelope module
# Not intended to be used directly
class antelope::params {
  # Group that should own the $ANTELOPE tree
  $dist_group = $::osfamily ? {
    'Darwin' => 'wheel',
    default  => 'root',
  }

  $service_provider = $::osfamily ? {
    'RedHat'  => $::operatingsystemmajrelease ? {
      7       => 'redhat',
      default => undef,
    },
    default => undef,
  }
}
