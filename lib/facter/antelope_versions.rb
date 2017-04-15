# Fact: antelope_versions
#
# The installed versions of BRTT Antelope on a system. It is determined
# by looking at /opt/antelope for # directories matching the Antelope
# version naming convention, and then # checks to see if setup.sh is
# present in the directory.
#
require 'facter/util/antelope'

module Facter
  module Antelope
    module Versions
      def self.add_facts

        if %w{Linux SunOS Darwin}.include? Facter.value(:kernel)
          versions = Facter::Util::Antelope.get_versions
          Facter.add(:antelope_versions) do
            setcode { versions.join(',') } unless versions.nil?
          end
          Facter.add(:antelope_versions_array) do
            setcode { versions } unless versions.nil?
          end
        end
      end
    end
  end
end
Facter::Antelope::Versions.add_facts
