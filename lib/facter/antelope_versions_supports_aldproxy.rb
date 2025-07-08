# frozen_string_literal: true

# Fact: antelope_versions_supports_aldproxy
#
require 'facter/util/antelope'

# Modern Facter 4+ structured facts
Facter.add(:antelope_versions_supports_aldproxy, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    versions = Facter::Util::Antelope.versions
    filtered_versions = versions&.select do |version|
      File.exist?("/opt/antelope/#{version}/bin/ald_proxy")
    end
    filtered_versions&.join(',')
  end
end

Facter.add(:antelope_versions_supports_aldproxy_array, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    versions = Facter::Util::Antelope.versions
    versions&.select do |version|
      File.exist?("/opt/antelope/#{version}/bin/ald_proxy")
    end
  end
end
