# Fact: antelope_contribbasedir
#

require 'facter/util/antelope'

module Facter
  module Antelope
    module ContribFact
      def self.add_facts
        Facter.add(:antelope_contrib_basedir) do
          confine :kernel => %w{Linux SunOS Darwin}
          result={}

          Facter::Util::Antelope.get_versions.each do |version|
            result[version]=''
            result[version]='/contrib' if \
              File.directory?("/opt/antelope/#{version}/contrib/bin")

            setcode { result } unless result.nil?
          end
        end
      end
    end
  end
end

Facter::Antelope::ContribFact.add_facts


