# Autorequires: File[$facts_dir]
class antelope::service_fact(
  $facts_dir = undef,
) inherits antelope::params {

  include ::antelope

  $facts_dir_real = $facts_dir ? {
    ''      => $::antelope::facts_dir,
    default => $facts_dir,
  }

  $file = "${facts_dir_real}/antelope_services"

  concat { $file:
    require => File[$facts_dir_real],
    mode    => '0755',
  }

  concat::fragment { "${file}_header" :
    target  => $file,
    order   => '00',
    content => '#!/usr/bin/perl
my @instances = <DATA>;
chomp @instances;
my $instancestr = join(",", @instances);
print "antelope_services=$instancestr\n";
__DATA__
',
  }
}
