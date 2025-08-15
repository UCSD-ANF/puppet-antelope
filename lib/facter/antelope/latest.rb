# frozen_string_literal: true

# Facts: antelope_latest_perl, antelope_latest_python, antelope_latest_version
#
# The path to the highest version of Perl and Python as distributed by BRTT
#
require 'facter/util/antelope'
require 'facter/antelope'

# Module for managing latest version facts
module Facter::Antelope::Latest
  # Generate facts for the latest (highest version) components of Antelope
  def self.add_facts
    add_latest_lambda = ->(id) do
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
      add_latest_lambda.call(factname)
    end
  end
end

# Auto-add facts when required
Facter::Antelope::Latest.add_facts
