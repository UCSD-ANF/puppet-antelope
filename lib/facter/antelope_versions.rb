# frozen_string_literal: true

# Fact: antelope_versions

require 'facter/util/antelope'

module Facter::Antelope
  # @summary
  #   The installed versions of BRTT Antelope on a system. The fact is
  #   determined by looking at /opt/antelope for directories matching
  #   the Antelopeversion naming convention, and then checks to see if
  #    setup.sh is present in the directory.
  #
  module Versions
    def self.add_facts
      versions = Facter::Util::Antelope.versions
      Facter.add(:antelope_versions) do
        confine kernel: Facter::Util::Antelope::VALID_KERNELS
        setcode { versions.join(',') } unless versions.nil?
      end
      Facter.add(:antelope_versions_array) do
        confine kernel: Facter::Util::Antelope::VALID_KERNELS
        setcode { versions } unless versions.nil?
      end
    end
  end
end

Facter::Antelope::Versions.add_facts
