# frozen_string_literal: true

# Fact: antelope_contribbasedir
require 'facter/util/antelope'

module Facter::Util::Contrib
  # @summary
  #   A facter fact to determine the location of the Antelope Contributed Software.
  #   This varies between older versions of Antelope and newer ones.
  class << self
    def contrib_subdir_exists?(version)
      File.directory?("/opt/antelope/#{version}/contrib/bin")
    end

    # Determines the contrib directories for all installed versions of Antelope.
    def contrib_dirs
      result = {}
      Facter::Util::Antelope.versions.each do |version|
        result[version] = if contrib_subdir_exists?(version)
                            '/contrib'
                          else
                            ''
                          end
      end
      result
    end
  end
end

Facter.add(:antelope_contrib_basedir) do
  setcode { Facter::Util::Contrib.contrib_dirs }
end
