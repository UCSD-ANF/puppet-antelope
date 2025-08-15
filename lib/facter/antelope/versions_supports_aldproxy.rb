# frozen_string_literal: true

# Fact: antelope_versions_supports_aldproxy
#
require 'facter/util/antelope'

# Module for managing ALD proxy facts
module Facter::Antelope::AldProxyFact
  # Create Fact for versions of Antelope that support the ALD Proxy license daemon
  def self.add_facts
    versions = Facter::Util::Antelope.versions
    unless versions.nil?
      versions = versions.delete_if do |version|
        File.exist?("/opt/antelope/#{version}/bin/ald_proxy") != true
      end
    end

    Facter.add(:antelope_versions_supports_aldproxy) do
      confine kernel: Facter::Util::Antelope::VALID_KERNELS
      setcode { versions.join(',') } unless versions.nil?
    end

    Facter.add(:antelope_versions_supports_aldproxy_array) do
      confine kernel: Facter::Util::Antelope::VALID_KERNELS
      setcode { versions } unless versions.nil?
    end
  end
end

# Auto-add facts when required
Facter::Antelope::AldProxyFact.add_facts
