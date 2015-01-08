# Fact: antelope_latest_perl and antelope_latest_python
#
# The path to the highest version of Perl and Python as distributed by BRTT
#
require 'facter/util/antelope'

module Facter::Antelope::Latest

  def self.getid(version, id)
    antelopepath="#{Facter::Util::Antelope::ANTELOPE_BASEDIR}/#{version}"
    res = %x{ ANTELOPE=#{antelopepath}; export ANTELOPE; #{antelopepath}/bin/getid #{id} 2> /dev/null}
    res.chomp!
    res
  end

  def self.add_latest(id)
    factname="antelope_latest_#{id}"
    Facter.add(factname) do
      confine :kernel => %w{Linux SunOS Darwin}
      setcode do
        latest_antelope = Facter.value(:antelope_latest_version)
        res = nil
        res=Facter::Antelope::Latest.getid(latest_antelope, id) if latest_antelope
        res
      end
    end
  end

  def self.add_facts
    Facter::Antelope::Latest.add_latest(:perl)
    Facter::Antelope::Latest.add_latest(:python)
  end
end
Facter::Antelope::Latest.add_facts
