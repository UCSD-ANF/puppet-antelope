# Autorequires: File[$facts_dir]
class antelope::service_fact(
  $facts_dir = $antelope::params::facts_dir
) inherits antelope::params {

  $file = "${facts_dir}/antelope_services"

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
my $instancestr = join(",", @instances);
print "antelope_services=$instancestr\n";
__DATA__
',
  }

}
