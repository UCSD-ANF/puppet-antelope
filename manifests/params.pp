# Parameters for the antelope module
# Not intended to be used directly
class antelope::params {
  # Group that should own the $ANTELOPE tree
  $dist_group = $::osfamily ? {
    'Darwin' => 'wheel',
    default  => 'root',
  }
}
