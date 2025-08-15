# frozen_string_literal: true

require_relative '../../antelope/version_utils'

##
## antelope.rb
##
## a set of utility methods to interact with a BRTT Antelope installation.
##
## Copyright (C) 2013-2020 The Regents of The University of California
## Author: Geoff Davis <gadavis@ucsd.edu>
##

# @summary
#   Utility functions for working with Antelope
module Facter::Util::Antelope
  extend Antelope::VersionUtils

  VALID_KERNELS = ['Linux', 'SunOS', 'Darwin'].freeze
  ANTELOPE_BASEDIR = '/opt/antelope'
  # Use the shared regex from the utility module
  RE_VERSION = Antelope::VersionUtils::RE_VERSION

  # Return a list of all Antelope versions installed on this system
  def self.versions
    dirs = Dir.entries(ANTELOPE_BASEDIR)
    versions = []

    dirs.each do |dir|
      dir = dir.chomp
      next unless RE_VERSION.match?(dir)
      next unless File.exist?(File.join(ANTELOPE_BASEDIR, dir, 'setup.sh'))
      versions.insert(-1, dir)
    end

    sort_antelope_versions(versions)
  rescue StandardError
    nil
  end

  def self.getid(version, id)
    antelopepath = "#{Facter::Util::Antelope::ANTELOPE_BASEDIR}/#{version}"
    res = `ANTELOPE=#{antelopepath}; export ANTELOPE; #{antelopepath}/bin/getid #{id} 2> /dev/null`
    res.chomp!
    res
  end

  # Sort Antelope versions from oldest to newest
  # 5.2-64 < 5.2-64p < 5.3pre < 5.3 < 5.3post
  # This method is kept for backward compatibility but now uses the shared comparison logic
  def self.sort_versions(a, b)
    compare_antelope_versions(a, b)
  end
end
