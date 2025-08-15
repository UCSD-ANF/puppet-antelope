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

#
# Antelope utility functions for Facter facts collection and system discovery.
#
# This module provides utility methods used by various Facter facts to discover,
# analyze, and work with Antelope installations on the system. It leverages the
# shared Antelope::VersionUtils module to ensure consistent version handling
# across the entire puppet-antelope module ecosystem.
#
# The utilities support discovery of multiple concurrent Antelope installations,
# version comparison and sorting, system integration, and path resolution for
# various Antelope components.
#
# **Integration with Shared Version Logic:**
# As of version 1.2.0, this utility module uses the shared Antelope::VersionUtils
# for all version comparison operations, ensuring consistency with Puppet functions
# and maintaining backward compatibility with existing fact implementations.
#
# **System Requirements:**
# - Supported kernels: Linux, SunOS, Darwin (macOS)
# - Standard Antelope installation in /opt/antelope
# - Valid setup.sh files in version directories
#
# @example Using in custom facts
#   Facter.add(:custom_antelope_info) do
#     setcode do
#       versions = Facter::Util::Antelope.versions
#       { 'count' => versions&.length || 0, 'versions' => versions }
#     end
#   end
#
# @example Integration with existing facts
#   # antelope_latest_version fact uses:
#   versions = Facter::Util::Antelope.versions
#   latest = versions&.last
#
# @since 1.0.0
# @see Antelope::VersionUtils Shared version comparison utilities
# @see antelope_versions Primary fact using this utility
# @see antelope_latest_version Fact for newest version detection
#
module Facter::Util::Antelope
  extend Antelope::VersionUtils

  #
  # Array of kernel names that support Antelope installations.
  #
  # These represent the operating systems where BRTT Antelope is
  # officially supported and where the puppet-antelope module
  # can manage installations.
  #
  # @since 1.0.0
  #
  VALID_KERNELS = ['Linux', 'SunOS', 'Darwin'].freeze

  #
  # Standard base directory for Antelope installations.
  #
  # This is the default location where BRTT Antelope software
  # is installed, containing subdirectories for each version.
  #
  # @example Directory structure
  #   /opt/antelope/
  #   ├── 5.3/
  #   ├── 5.4/
  #   ├── 5.5/
  #   └── 5.6/
  #
  # @since 1.0.0
  #
  ANTELOPE_BASEDIR = '/opt/antelope'

  #
  # Regular expression for validating Antelope version directory names.
  #
  # This is a reference to the shared regex from Antelope::VersionUtils
  # to ensure consistent version format validation across all components.
  #
  # @see Antelope::VersionUtils::RE_VERSION The source regex definition
  # @since 1.2.0
  #
  RE_VERSION = Antelope::VersionUtils::RE_VERSION

  #
  # Discover all Antelope version installations on the current system.
  #
  # Scans the standard Antelope base directory for subdirectories that
  # represent valid version installations. Each discovered version must:
  # 1. Have a directory name matching the Antelope version format
  # 2. Contain a valid setup.sh file indicating a complete installation
  #
  # The returned versions are sorted using Antelope-specific comparison
  # rules via the shared VersionUtils module, ensuring proper ordering
  # across 64-bit transitions and pre/post releases.
  #
  # This method is used by multiple Facter facts including antelope_versions
  # and antelope_latest_version to provide system information to Puppet
  # manifests.
  #
  # @return [Array<String>, nil] Sorted array of version strings from oldest to newest,
  #   or nil if an error occurs during discovery
  #
  # @example Successful discovery
  #   Facter::Util::Antelope.versions
  #   # => ['5.3', '5.4', '5.4-64', '5.5pre', '5.5', '5.6']
  #
  # @example No installations found
  #   Facter::Util::Antelope.versions  # (empty /opt/antelope)
  #   # => []
  #
  # @example Error condition
  #   Facter::Util::Antelope.versions  # (permission denied, etc.)
  #   # => nil
  #
  # @example Mixed version formats with proper sorting
  #   # Directory contents: 5.5, 5.4-64, 5.3, 5.5pre, 5.4
  #   Facter::Util::Antelope.versions
  #   # => ['5.3', '5.4', '5.4-64', '5.5pre', '5.5']
  #
  # @see #sort_antelope_versions For version sorting logic
  # @see ANTELOPE_BASEDIR For the installation directory
  # @see RE_VERSION For version format validation
  # @see antelope_versions Fact that uses this method
  # @see antelope_latest_version Fact that uses this method
  #
  # @since 1.0.0
  #
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

  #
  # Execute the Antelope 'getid' utility to retrieve system information.
  #
  # The getid utility is part of the Antelope toolkit and provides various
  # system identifiers and configuration information. This method sets up
  # the proper Antelope environment and executes getid with error handling.
  #
  # **Environment Setup:**
  # - Sets ANTELOPE environment variable to version-specific path
  # - Uses the version-specific binary directory
  # - Suppresses stderr output for cleaner results
  #
  # @param version [String] Antelope version to use for getid execution
  # @param id [String] Identifier type to retrieve (e.g., 'dbname', 'hostname')
  #
  # @return [String] The getid command output with whitespace stripped
  #
  # @example Get database name
  #   getid('5.5', 'dbname')  # => 'demo'
  #
  # @example Get system hostname
  #   getid('5.5', 'hostname')  # => 'seismic.example.com'
  #
  # @example Invalid version or ID
  #   getid('nonexistent', 'dbname')  # => '' (empty string)
  #
  # @note This method is used internally by other utilities and facts that
  #   need to retrieve Antelope-specific configuration information.
  #
  # @see ANTELOPE_BASEDIR For the base installation directory
  #
  # @since 1.0.0
  #
  def self.getid(version, id)
    antelopepath = "#{Facter::Util::Antelope::ANTELOPE_BASEDIR}/#{version}"
    res = `ANTELOPE=#{antelopepath}; export ANTELOPE; #{antelopepath}/bin/getid #{id} 2> /dev/null`
    res.chomp!
    res
  end

  #
  # Sort two Antelope versions using Antelope-specific comparison rules.
  #
  # This method provides backward compatibility with older code that used
  # direct version sorting. It now delegates to the shared comparison logic
  # to ensure consistency across the entire puppet-antelope module.
  #
  # **Version Ordering Examples:**
  # - `5.2-64 < 5.2-64p < 5.3pre < 5.3 < 5.3post`
  # - `5.4 < 5.4-64` (pre-5.5 transition)
  # - `5.5-64 < 5.5` (post-5.5 transition)
  #
  # @param a [String] First version to compare
  # @param b [String] Second version to compare
  #
  # @return [Integer] Comparison result:
  #   - `-1` if a < b
  #   - `0` if a == b
  #   - `1` if a > b
  #
  # @example Direct version comparison
  #   sort_versions('5.4', '5.5')      # => -1
  #   sort_versions('5.5pre', '5.5')   # => -1
  #   sort_versions('5.4-64', '5.4')   # => 1
  #
  # @example Usage in sorting blocks
  #   versions.sort { |a, b| Facter::Util::Antelope.sort_versions(a, b) }
  #
  # @deprecated This method is kept for backward compatibility. New code should
  #   use the shared Antelope::VersionUtils#compare_antelope_versions directly
  #   or the #sort_antelope_versions utility method.
  #
  # @see Antelope::VersionUtils#compare_antelope_versions The underlying implementation
  # @see #sort_antelope_versions For array sorting utility
  #
  # @since 1.0.0
  #
  def self.sort_versions(a, b)
    compare_antelope_versions(a, b)
  end
end
