# frozen_string_literal: true

# Fact: antelope_contribbasedir
require 'facter/util/antelope'

module Facter::Antelope
  module Contrib
    # @summary
    #   A facter fact to determine the location of the Antelope Contributed Software.
    #   This varies between older versions of Antelope and newer ones.

    def self.contrib_subdir_exists?(version)
      File.directory?("/opt/antelope/#{version}/contrib/bin")
    end

    # Determines the contrib directories for all installed versions of Antelope.
    def self.contrib_dirs
      #result = {'junk'=>'value'}
      result = Facter::Util::Antelope.versions.map { |version|
        ["#{version}", self.contrib_subdir_exists?(version)? '/contrib': '']}.to_h
      result
    end

    def self.add_facts
      Facter.add(:antelope_contrib_basedir) do
        confine kernel: Facter::Util::Antelope::VALID_KERNELS
        setcode { Facter::Antelope::Contrib.contrib_dirs }
      end
    end
  end
end

Facter::Antelope::Contrib.add_facts
