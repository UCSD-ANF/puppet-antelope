# Fact: antelope_latest_perl
#
# The path to the highest version of Perl as distributed by BRTT
#

Facter.add(:antelope_latest_perl) do

  confine :kernel => %w{Linux SunOS Darwin}

  setcode do
    # Antelope always lives under this directory
    antbasedir = '/opt/antelope'
    perl = nil

    latestantelope = Facter.value('antelope_latest_version')
    if latestantelope
      antelopepath="#{antbasedir}/#{latestantelope}"
      perl = %x{ ANTELOPE=#{antelopepath}; export ANTELOPE; #{antelopepath}/bin/getid perl 2> /dev/null}
      perl.chomp!
    end

    perl
  end
end
