# Fact: antelope_supports_aldproxy
#

require 'facter/util/antelope'

module Facter
  module Antelope
    module AldProxyFact
      def self.add_facts
        Facter.add(:antelope_supports_aldproxy) do
          confine :kernel => %w{Linux Darwin}
          result={}
          begin
            Facter::Util::Antelope.get_versions.each do |antver|
              result[antver]=false
              result[antver]=true if \
                File.exist?("/opt/antelope/#{antver}/bin/ald_proxy")
            end
          rescue
            result = nil
          end
          setcode { result } unless result.nil?
        end
      end
    end
  end
end

Facter::Antelope::AldProxyFact.add_facts
