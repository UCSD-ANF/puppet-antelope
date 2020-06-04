# frozen_string_literal: true

# Fact: antelope_versions
#
# The installed versions of BRTT Antelope on a system. It is determined
# by looking at /opt/antelope for # directories matching the Antelope
# version naming convention, and then # checks to see if setup.sh is
# present in the directory.
#
require 'facter/util/antelope'

module Facter::Antelope
  module Versions
    def self.add_facts
      confine kernel: Facter::Util::Antelope::VALID_KERNELS
      versions = Facter::Util::Antelope.versions
      Facter.add(:antelope_versions) do
        setcode { versions.join(',') } unless versions.nil?
      end
      Facter.add(:antelope_versions_array) do
        setcode { versions } unless versions.nil?
      end
    end
  end
end

Facter::Antelope::Versions.add_facts
