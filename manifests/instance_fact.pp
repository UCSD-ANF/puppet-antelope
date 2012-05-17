class antelope::instance_fact(
  $file = "${antelope::params::facts_dir}/antelope_instance_fact"
) inherits antelope::params {
  include concat::setup

  concat { $file:
    mode => '0755',
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
