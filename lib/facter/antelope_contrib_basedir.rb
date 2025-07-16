# frozen_string_literal: true

# Fact: antelope_contribbasedir
require 'facter/util/antelope'

# @summary Helper method to check if contrib subdirectory exists
# @param version [String] Antelope version string
# @return [Boolean] true if contrib subdirectory exists, false otherwise
def contrib_subdir_exists?(version)
  File.directory?("/opt/antelope/#{version}/contrib/bin")
end

# Modern Facter 4+ structured facts
Facter.add(:antelope_contrib_basedir, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    versions = Facter::Util::Antelope.versions
    next nil if versions.nil?

    versions.map { |version|
      [version, contrib_subdir_exists?(version) ? '/contrib' : '']
    }.to_h
  end
end
