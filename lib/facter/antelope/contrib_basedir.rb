# frozen_string_literal: true

# Fact: antelope_contribbasedir
require 'facter/util/antelope'
require 'facter/antelope'

# Facter fact to determine the location of the Antelope Contributed Software
# This varies between older versions of Antelope and newer ones
# @summary
#   A facter fact to determine the location of the Antelope Contributed Software.
#   This varies between older versions of Antelope and newer ones.

# Module for managing contrib directory facts
module Facter::Antelope::Contrib
  def self.contrib_subdir_exists?(version)
    File.directory?("/opt/antelope/#{version}/contrib/bin")
  end

  # Determines the contrib directories for all installed versions of Antelope.
  def self.contrib_dirs
    result = Facter::Util::Antelope.versions.map { |version|
      [version, contrib_subdir_exists?(version) ? '/contrib' : '']
    }.to_h
    result
  end
end

Facter.add(:antelope_contrib_basedir) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode { Facter::Antelope::Contrib.contrib_dirs }
end
