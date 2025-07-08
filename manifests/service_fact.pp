# @summary Installs a service fact for Antelope services
#
# This class sets up a basic concat resource that other classes can add to
# in order to build the antelope_services fact. The fact contains a comma-separated
# list of all Antelope service instances.
#
# @param facts_dir
#   Path to the facter facts.d directory
#
# @example Basic usage
#   include antelope::service_fact
#
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
