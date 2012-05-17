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
chomp @instances;
my $instancestr = join(",", chomp @instances);
print "antelope_instance_fact=$instancestr\n";
__DATA__
',
  }

}
