# frozen_string_literal: true

##
## antelope.rb
##
## a set of utility methods to interact with a BRTT Antelope installation.
##
## Copyright (C) 2013-2020 The Regents of The University of California
## Author: Geoff Davis <gadavis@ucsd.edu>
##

# Utility functions for working with Antelope
#
# This module provides helper methods for working with BRTT Antelope installations,
# including version detection, path handling, and environment setup.
module Facter::Util::Antelope
  # Valid operating system kernels for Antelope
  # @return [Array<String>] List of supported kernel names
  VALID_KERNELS = ['Linux', 'SunOS', 'Darwin'].freeze

  # Base directory where Antelope is installed
  # @return [String] Absolute path to Antelope installation directory
  ANTELOPE_BASEDIR = '/opt/antelope'

  # Regular expression to match Antelope version strings
  # @return [Regexp] Pattern for matching version strings like "5.15" or "5.2-64"
  RE_VERSION = %r{^(\d+)\.(\d+)(-64)?(pre|post|p)?$}

  # @summary Return a list of all Antelope versions installed on this system
  # @return [Array<String>, nil] Array of version strings sorted from oldest to newest, or nil if error
  def self.versions
    dirs = Dir.entries(ANTELOPE_BASEDIR)
    versions = []

    dirs.each do |dir|
      dir = dir.chomp
      next unless dir.match?(RE_VERSION)
      next unless File.exist?(File.join(ANTELOPE_BASEDIR, dir, 'setup.sh'))
      versions.insert(-1, dir)
    end

    versions.sort { |a, b| sort_versions(a, b) }
  rescue StandardError
    nil
  end

  # @summary Get information about an Antelope installation using the getid command
  # @param version [String] Antelope version string
  # @param id [Symbol] Type of information to retrieve (e.g., :perl, :python)
  # @return [String] Result from the getid command
  def self.getid(version, id)
    antelopepath = "#{Facter::Util::Antelope::ANTELOPE_BASEDIR}/#{version}"
    res = `ANTELOPE=#{antelopepath}; export ANTELOPE; #{antelopepath}/bin/getid #{id} 2> /dev/null`
    res.chomp!
    res
  end

  # @summary Sort Antelope versions from oldest to newest
  # @param a [String] First version string to compare
  # @param b [String] Second version string to compare
  # @return [Integer] -1 if a < b, 0 if a == b, 1 if a > b
  # @example Version ordering
  #   5.2-64 < 5.2-64p < 5.3pre < 5.3 < 5.3post
  def self.sort_versions(a, b)
    amatch = RE_VERSION.match(a)
    bmatch = RE_VERSION.match(b)

    if Integer(amatch[1]) < Integer(bmatch[1])
      return -1
    end
    if Integer(amatch[1]) > Integer(bmatch[1])
      return 1
    end

    # major is equal
    if Integer(amatch[2]) < Integer(bmatch[2])
      return -1
    end
    if Integer(amatch[2]) > Integer(bmatch[2])
      return 1
    end

    # major and minor are equal
    # check the bits
    if amatch[3].nil? && !bmatch[3].nil?
      return 1
    end
    if bmatch[3].nil? && !amatch[3].nil?
      return +1
    end

    # Major, minor, and bits are equal
    # Check the suffix for pre release versus post-release
    if amatch[4] == bmatch[4]
      return 0
    end
    if amatch[4] == 'pre'
      return -1
    end
    if bmatch[4] == 'pre'
      return 1
    end
    if (amatch[4] == 'p') || (amatch[4] == 'post')
      return 1
    end
    -1
  end
end
