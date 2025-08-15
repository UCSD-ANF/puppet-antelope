# Autorequires: File[$facts_dir]
# Installs a service fact for Antelope services
# Sets up a basic concat resource that other classes can add to
# @param facts_dir The directory where custom facts should be stored. Typically '/etc/facter/facts.d'.
class antelope::service_fact (
  Stdlib::Absolutepath  $facts_dir,
) {
  include antelope

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
