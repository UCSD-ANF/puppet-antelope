# Autorequires: File[$facts_dir]
class antelope::instance_fact(
  $facts_dir = $antelope::params::facts_dir
) inherits antelope::params {
  include concat::setup

  $file = "${facts_dir}/antelope_instance_fact"

  concat { $file:
    require => File[$facts_dir],
    mode    => '0755',
  }

  concat::fragment { "${file}_header" :
    target  => $file,
    order   => '00',
    content => '#!/usr/bin/perl
my @instances = <DATA>;
my $instances = join(",", chomp @instances);
print "instance_fact=$instances\n";
__DATA__
',
  }

}
