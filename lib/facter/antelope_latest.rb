# frozen_string_literal: true

# Facts: antelope_latest_perl, antelope_latest_python, antelope_latest_version
#
# The path to the highest version of Perl and Python as distributed by BRTT
#
require 'facter/util/antelope'

module Facter::Antelope
  # Generate facts for the latest (highest version) components of Antelope.
  module Latest
    def self.add_latest(id)
      factname = "antelope_latest_#{id}"
      Facter.add(factname) do
        confine kernel: Facter::Util::Antelope::VALID_KERNELS
        setcode do
          latest_antelope = Facter.value(:antelope_latest_version)
          res = nil
          res = Facter::Util::Antelope.getid(latest_antelope, id) if latest_antelope
          res
        end
      end
    end

    def self.add_facts
      Facter.add(:antelope_latest_version) do
        confine kernel: Facter::Util::Antelope::VALID_KERNELS
        setcode do
          versions = Facter::Util::Antelope.versions
          version = nil
          version = versions.last unless versions.nil?
          version
        end
      end

      [:perl, :python].each do |factname|
        Facter::Antelope::Latest.add_latest(factname)
      end
    end
  end
end

Facter::Antelope::Latest.add_facts
