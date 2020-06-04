# frozen_string_literal: true

# Fact: antelope_versions_supports_aldproxy
#
require 'facter/util/antelope'

module Facter::Antelope
  module AldProxyFact
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
end
Facter::Antelope::AldProxyFact.add_facts
