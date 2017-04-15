# Fact: antelope_versions_supports_aldproxy
#
require 'facter/util/antelope'

module Facter
  module Antelope
    module AldProxyFact
      def self.add_facts

        if %w{Linux Darwin}.include? Facter.value(:kernel)
          versions = Facter::Util::Antelope.get_versions
          versions = versions.delete_if { |version|
            true != File.exist?("/opt/antelope/#{version}/bin/ald_proxy")
          } unless versions.nil?
          Facter.add(:antelope_versions_supports_aldproxy) do
            setcode { versions.join(',') } unless versions.nil?
          end
          Facter.add(:antelope_versions_supports_aldproxy_array) do
            setcode { versions } unless versions.nil?
          end
        end
      end
    end
  end
end
Facter::Antelope::AldProxyFact.add_facts
