# Fact: antelope_versions
#
# The installed versions of BRTT Antelope on a system. It is determined
# by looking at /opt/antelope for # directories matching the Antelope
# version naming convention, and then # checks to see if setup.sh is
# present in the directory.
#

require 'facter/util/antelope'

Facter.add(:antelope_versions) do

  confine :kernel => %w{Linux SunOS Darwin}

  versions = Facter::Util::Antelope.get_versions
  unless versions.nil?
    setcode do
      return versions.join(',')
    end
  end

end

Facter.add(:antelope_versions_array) do

  confine :kernel => %w{Linux SunOS Darwin}

  versions = Facter::Util::Antelope.get_versions
  unless versions.nil?
    setcode do
      return versions
    end
  end

end

