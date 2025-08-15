# frozen_string_literal: true

require_relative '../../../antelope/version_utils'

#
# Puppet function for comparing Antelope version strings with comprehensive versioning rules.
#
# This function provides Puppet manifests with sophisticated version comparison
# capabilities that understand Antelope-specific versioning conventions, including
# the 64-bit architecture transition, pre/post release suffixes, and semantic
# versioning rules.
#
# The function leverages the shared Antelope::VersionUtils module to ensure
# consistent version comparison logic across both Puppet functions and Facter
# utilities throughout the puppet-antelope module.
#
# **Key Features:**
# - Handles the 32-bit to 64-bit transition at version 5.5
# - Supports pre/post/p release suffix ordering
# - Provides strict version format validation
# - Thread-safe implementation for Puppet catalog compilation
#
# @since 1.2.0
# @see Antelope::VersionUtils The underlying implementation module
#
Puppet::Functions.create_function(:'antelope::version_compare') do
  #
  # @summary Compare two Antelope version strings using Antelope-specific versioning rules
  #
  # This function compares two Antelope version strings and returns an integer
  # indicating their relative ordering. The comparison implements comprehensive
  # Antelope versioning rules including semantic versioning, 64-bit architecture
  # suffix handling, and pre/post release version ordering.
  #
  # **Version Comparison Rules:**
  #
  # 1. **Semantic Versioning**: Major.minor comparison (5.4 < 5.5 < 5.10)
  # 2. **64-bit Architecture Handling**:
  #    - For versions 5.5+: no suffix > -64 suffix (5.5+ are 64-bit only)
  #    - For versions <5.5: -64 suffix > no suffix (transition period)
  # 3. **Release Suffix Ordering**: pre < release < post/p
  # 4. **Format Validation**: Strict validation with descriptive error messages
  #
  # **Architecture Transition Logic:**
  # The function correctly handles the Antelope 64-bit transition that occurred
  # at version 5.5, where 64-bit builds became the standard and the -64 suffix
  # became legacy.
  #
  # @param version1 [String] First version string to compare
  #   Valid formats: '5.4', '5.5-64', '5.5pre', '5.4post', '5.3p'
  # @param version2 [String] Second version string to compare
  #   Valid formats: '5.4', '5.5-64', '5.5pre', '5.4post', '5.3p'
  #
  # @return [Integer] Comparison result:
  #   - `-1` if version1 < version2
  #   - `0` if version1 == version2
  #   - `1` if version1 > version2
  #
  # @raise [ArgumentError] If either version string format is invalid
  #
  # @example Basic semantic version comparison
  #   antelope::version_compare('5.4', '5.5')        # Returns -1 (5.4 < 5.5)
  #   antelope::version_compare('5.5', '5.4')        # Returns 1  (5.5 > 5.4)
  #   antelope::version_compare('5.4', '5.4')        # Returns 0  (equal)
  #   antelope::version_compare('5.10', '5.9')       # Returns 1  (5.10 > 5.9)
  #
  # @example 64-bit architecture transition handling
  #   # Post-transition (5.5+): no suffix is newer
  #   antelope::version_compare('5.5', '5.5-64')     # Returns 1  (newer)
  #   antelope::version_compare('5.6', '5.6-64')     # Returns 1  (newer)
  #
  #   # Pre-transition (<5.5): -64 suffix is newer
  #   antelope::version_compare('5.4-64', '5.4')     # Returns 1  (newer)
  #   antelope::version_compare('5.3', '5.3-64')     # Returns -1 (older)
  #
  # @example Pre/post release version handling
  #   antelope::version_compare('5.5pre', '5.5')     # Returns -1 (pre < release)
  #   antelope::version_compare('5.5', '5.5post')    # Returns -1 (release < post)
  #   antelope::version_compare('5.5', '5.5p')       # Returns -1 (release < p)
  #   antelope::version_compare('5.5pre', '5.5post') # Returns -1 (pre < post)
  #
  # @example Practical manifest usage with conditionals
  #   # Version-based feature enablement
  #   if antelope::version_compare($antelope_version, '5.5') >= 0 {
  #     # Use 5.5+ specific configuration
  #     $enable_64bit_features = true
  #     $use_modern_config = true
  #   } else {
  #     # Use legacy configuration for older versions
  #     $enable_64bit_features = false
  #     $use_modern_config = false
  #   }
  #
  # @example Version requirement validation
  #   # Ensure minimum version requirements are met
  #   $required_version = '5.3'
  #   if antelope::version_compare($current_version, $required_version) < 0 {
  #     fail("Antelope version ${current_version} is older than required ${required_version}")
  #   }
  #
  # @example Integration with Antelope facts for dynamic configuration
  #   # Using with antelope_latest_version fact
  #   $latest_version = $facts['antelope_latest_version']
  #   if antelope::version_compare($latest_version, '5.5') >= 0 {
  #     include antelope::modern_config
  #   } else {
  #     include antelope::legacy_config
  #   }
  #
  #   # Multi-version environment handling
  #   $versions = $facts['antelope_versions']
  #   $sorted_versions = $versions.sort |$a, $b| {
  #     antelope::version_compare($a, $b)
  #   }
  #   $newest_version = $sorted_versions[-1]
  #
  # @example Resource management based on version capabilities
  #   # Conditional resource inclusion based on feature availability
  #   if antelope::version_compare($antelope_version, '5.3') >= 0 {
  #     # aldproxy feature available
  #     antelope::instance { 'realtime':
  #       use_aldproxy => true,
  #     }
  #   } else {
  #     # Legacy configuration without aldproxy
  #     antelope::instance { 'realtime':
  #       use_aldproxy => false,
  #     }
  #   }
  #
  # @example Error handling in manifests
  #   # Graceful handling of invalid versions
  #   $result = try {
  #     antelope::version_compare($user_provided_version, '5.5')
  #   } catch {
  #     notify { 'Invalid version format provided by user': }
  #     -1  # Default to treating as older
  #   }
  #
  # @see Antelope::VersionUtils#compare_antelope_versions The underlying implementation
  # @see antelope_latest_version Facter fact for latest installed version
  # @see antelope_versions Facter fact for all installed versions
  # @see antelope::instance Defined type that uses version-specific configuration
  #
  # @since 1.2.0
  #
  dispatch :compare do
    param 'String', :version1
    param 'String', :version2
    return_type 'Integer'
  end

  #
  # Implementation method that delegates to the shared utility module.
  #
  # This method acts as a thin wrapper around the shared
  # Antelope::VersionUtils#compare_antelope_versions method, ensuring that
  # both Puppet functions and Facter utilities use identical version
  # comparison logic throughout the puppet-antelope module.
  #
  # @param version1 [String] First version to compare
  # @param version2 [String] Second version to compare
  #
  # @return [Integer] Comparison result (-1, 0, or 1)
  #
  # @raise [ArgumentError] If either version format is invalid
  #
  # @api private
  # @since 1.2.0
  #
  def compare(version1, version2)
    # Include the shared utility module and use its methods
    extend Antelope::VersionUtils
    # Use the shared utility method for consistent comparison logic
    compare_antelope_versions(version1, version2)
  end
end
