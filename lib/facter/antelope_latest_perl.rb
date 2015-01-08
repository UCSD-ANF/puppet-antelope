# Fact: antelope_latest_perl
#
# The path to the highest version of Perl as distributed by BRTT
#
require 'facter/util/antelope'

module Facter::Antelope::LatestPerl

  def self.getid(version)
    antelopepath="#{Facter::Util::Antelope::ANTELOPE_BASEDIR}/#{version}"
    perl = %x{ ANTELOPE=#{antelopepath}; export ANTELOPE; #{antelopepath}/bin/getid perl 2> /dev/null}
    perl.chomp!
    perl
  end

  def self.add_facts
    Facter.add(:antelope_latest_perl) do

      confine :kernel => %w{Linux SunOS Darwin}
      setcode do
        perl = nil
        latest_antelope = Facter.value('antelope_latest_version')
        perl=Facter::Antelope::LatestPerl.getid(latest_antelope) if latest_antelope
        perl
      end
    end
  end
end
Facter::Antelope::LatestPerl.add_facts
