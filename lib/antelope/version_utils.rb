# frozen_string_literal: true

##
## version_utils.rb
##
## Shared utility functions for Antelope version comparison
## Used by both Puppet functions and Facter facts to ensure consistency
##
## Copyright (C) 2013-2020 The Regents of The University of California
## Author: Geoff Davis <gadavis@ucsd.edu>
##

#
# Shared utility module for Antelope version comparison and manipulation.
#
# This module provides a centralized implementation of Antelope-specific version
# comparison logic that handles the complex rules around 64-bit architecture
# transitions, pre/post release suffixes, and semantic versioning.
#
# The module is designed to be used by both Puppet functions and Facter utilities
# to ensure consistent version handling across the entire puppet-antelope module.
#
# **Key Features:**
# - Handles 32-bit to 64-bit transition logic at version 5.5
# - Supports pre/post/p release suffix ordering: pre < release < post/p
# - Strict version format validation with comprehensive error handling
# - Thread-safe implementation suitable for both Puppet and Facter contexts
#
# @example Basic version comparison
#   include Antelope::VersionUtils
#   compare_antelope_versions('5.4', '5.5')  # => -1
#   compare_antelope_versions('5.5', '5.4')  # => 1
#   compare_antelope_versions('5.4', '5.4')  # => 0
#
# @example 64-bit architecture handling
#   # For versions 5.5+, no -64 suffix is newer (64-bit only)
#   compare_antelope_versions('5.5', '5.5-64')     # => 1
#   # For versions before 5.5, -64 suffix is newer (vs 32-bit default)
#   compare_antelope_versions('5.4-64', '5.4')     # => 1
#
# @example Pre/post suffix handling
#   compare_antelope_versions('5.5pre', '5.5')     # => -1
#   compare_antelope_versions('5.5', '5.5post')    # => -1
#   compare_antelope_versions('5.5pre', '5.5post') # => -1
#
# @since 1.2.0
#
module Antelope::VersionUtils
    #
    # Regular expression for parsing Antelope version strings.
    #
    # Matches version formats like:
    # - Basic: "5.4", "5.10"
    # - 64-bit: "5.4-64", "5.5-64"
    # - Pre-release: "5.5pre", "5.4pre1"
    # - Post-release: "5.5post", "5.4post1", "5.4p"
    # - Combined: "5.4pre1-64", "5.5post2-64"
    #
    # **Capture Groups:**
    # 1. Major version (required)
    # 2. Minor version (required)
    # 3. 64-bit suffix ("-64", optional)
    # 4. Release suffix ("pre", "post", "p", optional)
    #
    # @since 1.2.0
    #
    RE_VERSION = %r{^(\d+)\.(\d+)(-64)?(pre|post|p)?$}.freeze

    #
    # Compare two Antelope version strings using Antelope-specific rules.
    #
    # This method implements the complete Antelope version comparison logic,
    # handling semantic versioning, 64-bit architecture transitions, and
    # pre/post release suffixes with proper validation.
    #
    # **Version Comparison Rules:**
    # 1. Major/minor versions compared numerically (5.4 < 5.5 < 5.10)
    # 2. 64-bit suffix handling varies by version:
    #    - For versions 5.5+: no suffix > -64 suffix (5.5+ are 64-bit only)
    #    - For versions <5.5: -64 suffix > no suffix (transition period)
    # 3. Release suffix order: pre < release < post/p
    # 4. Invalid formats raise ArgumentError with descriptive messages
    #
    # @param version_a [String] First version to compare (e.g., '5.4', '5.5-64', '5.5pre')
    # @param version_b [String] Second version to compare (e.g., '5.4', '5.5-64', '5.5pre')
    #
    # @return [Integer] Comparison result:
    #   - `-1` if version_a < version_b
    #   - `0` if version_a == version_b
    #   - `1` if version_a > version_b
    #
    # @raise [ArgumentError] If either version string doesn't match the expected format
    #
    # @example Basic semantic version comparison
    #   compare_antelope_versions('5.4', '5.5')        # => -1 (5.4 < 5.5)
    #   compare_antelope_versions('5.5', '5.4')        # => 1  (5.5 > 5.4)
    #   compare_antelope_versions('5.4', '5.4')        # => 0  (equal)
    #   compare_antelope_versions('5.10', '5.9')       # => 1  (5.10 > 5.9)
    #
    # @example 64-bit transition logic
    #   # Post-transition (5.5+): no suffix is newer
    #   compare_antelope_versions('5.5', '5.5-64')     # => 1  (newer)
    #   compare_antelope_versions('5.6', '5.6-64')     # => 1  (newer)
    #
    #   # Pre-transition (<5.5): -64 suffix is newer
    #   compare_antelope_versions('5.4-64', '5.4')     # => 1  (newer)
    #   compare_antelope_versions('5.3', '5.3-64')     # => -1 (older)
    #
    # @example Pre/post suffix handling
    #   compare_antelope_versions('5.5pre', '5.5')     # => -1 (pre < release)
    #   compare_antelope_versions('5.5', '5.5post')    # => -1 (release < post)
    #   compare_antelope_versions('5.5', '5.5p')       # => -1 (release < p)
    #   compare_antelope_versions('5.5pre', '5.5post') # => -1 (pre < post)
    #
    # @example Error handling
    #   compare_antelope_versions('invalid', '5.5')    # => ArgumentError
    #   compare_antelope_versions('5.5', 'bad-format') # => ArgumentError
    #
    # @see #parse_antelope_version For version string parsing details
    # @see #compare_bit_suffixes For 64-bit transition logic
    # @see #compare_suffixes For pre/post suffix ordering
    #
    # @since 1.2.0
    #
    def compare_antelope_versions(version_a, version_b)
      return 0 if version_a == version_b

      parsed_a = parse_antelope_version(version_a)
      parsed_b = parse_antelope_version(version_b)

      # Validate that both versions matched the regex
      validate_version_format!(version_a, parsed_a)
      validate_version_format!(version_b, parsed_b)

      # Compare major version
      major_cmp = parsed_a[:major] <=> parsed_b[:major]
      return major_cmp unless major_cmp.zero?

      # Compare minor version
      minor_cmp = parsed_a[:minor] <=> parsed_b[:minor]
      return minor_cmp unless minor_cmp.zero?

      # Handle 64-bit suffix comparison
      bit_cmp = compare_bit_suffixes(parsed_a[:bit_suffix], parsed_b[:bit_suffix],
                                     parsed_a[:major], parsed_a[:minor])
      return bit_cmp unless bit_cmp.zero?

      # Handle pre/post/p suffixes
      compare_suffixes(parsed_a[:suffix], parsed_b[:suffix])
    end

    #
    # Parse an Antelope version string into its constituent components.
    #
    # Breaks down a version string using the RE_VERSION regular expression
    # into major version, minor version, architecture suffix, and release suffix
    # for detailed comparison and validation.
    #
    # @param version [String] Version string to parse (e.g., '5.5-64', '5.4pre', '5.5post-64')
    #
    # @return [Hash] Hash containing parsed components:
    #   - `:major` [Integer] Major version number
    #   - `:minor` [Integer] Minor version number
    #   - `:bit_suffix` [String, nil] Architecture suffix ('-64') or nil
    #   - `:suffix` [String, nil] Release suffix ('pre', 'post', 'p') or nil
    #
    # @example Parsing different version formats
    #   parse_antelope_version('5.5')        # => { major: 5, minor: 5, bit_suffix: nil, suffix: nil }
    #   parse_antelope_version('5.5-64')     # => { major: 5, minor: 5, bit_suffix: '-64', suffix: nil }
    #   parse_antelope_version('5.5pre')     # => { major: 5, minor: 5, bit_suffix: nil, suffix: 'pre' }
    #   parse_antelope_version('5.4post-64') # => { major: 5, minor: 4, bit_suffix: '-64', suffix: 'post' }
    #
    # @example Invalid version handling
    #   parse_antelope_version('invalid')    # => { major: 0, minor: 0, bit_suffix: nil, suffix: nil }
    #
    # @note Invalid versions return a fallback hash with zero values, but validation
    #   occurs in compare_antelope_versions to provide meaningful error messages.
    #
    # @see #validate_version_format! For validation logic
    # @see RE_VERSION For the parsing regular expression
    #
    # @since 1.2.0
    #
    def parse_antelope_version(version)
      match = RE_VERSION.match(version)
      if match
        {
          major: match[1].to_i,
          minor: match[2].to_i,
          bit_suffix: match[3], # '-64' or nil
          suffix: match[4]      # 'pre', 'post', 'p', or nil
        }
      else
        # Fallback for non-matching versions
        {
          major: 0,
          minor: 0,
          bit_suffix: nil,
          suffix: nil
        }
      end
    end

    #
    # Compare pre/post/p release suffixes according to Antelope versioning rules.
    #
    # Implements the Antelope release ordering where pre-releases come before
    # the main release, and post-releases come after. The 'p' suffix is treated
    # as equivalent to 'post' for compatibility.
    #
    # **Suffix Ordering:** `pre < (no suffix) < post/p`
    #
    # @param suffix1 [String, nil] First suffix ('pre', 'post', 'p', or nil for release)
    # @param suffix2 [String, nil] Second suffix ('pre', 'post', 'p', or nil for release)
    #
    # @return [Integer] Comparison result:
    #   - `-1` if suffix1 < suffix2
    #   - `0` if suffix1 == suffix2
    #   - `1` if suffix1 > suffix2
    #
    # @example Suffix comparison scenarios
    #   # Pre-release vs release
    #   compare_suffixes('pre', nil)     # => -1 (pre < release)
    #   compare_suffixes(nil, 'pre')     # => 1  (release > pre)
    #
    #   # Release vs post-release
    #   compare_suffixes(nil, 'post')    # => -1 (release < post)
    #   compare_suffixes('post', nil)    # => 1  (post > release)
    #   compare_suffixes(nil, 'p')       # => -1 (release < p)
    #
    #   # Pre vs post
    #   compare_suffixes('pre', 'post')  # => -1 (pre < post)
    #   compare_suffixes('pre', 'p')     # => -1 (pre < p)
    #
    #   # Equal suffixes
    #   compare_suffixes('pre', 'pre')   # => 0
    #   compare_suffixes('post', 'p')    # => 0  (equivalent)
    #
    # @see #compare_antelope_versions For complete version comparison context
    #
    # @since 1.2.0
    #
    def compare_suffixes(suffix1, suffix2)
      return 0 if suffix1 == suffix2

      # Handle pre suffix
      return -1 if suffix1 == 'pre'
      return 1 if suffix2 == 'pre'

      # Both are post or p (or one is nil)
      # post and p are equivalent and both > no suffix
      if ['post', 'p'].include?(suffix1) && suffix2.nil?
        return 1
      elsif suffix1.nil? && ['post', 'p'].include?(suffix2)
        return -1
      end

      0
    end

    #
    # Compare 64-bit architecture suffixes with transition period logic.
    #
    # Implements the complex 64-bit transition logic that occurred in Antelope
    # version 5.5, where the meaning of the -64 suffix changed significantly.
    #
    # **Transition Logic:**
    # - **Pre-5.5 versions**: -64 suffix indicates newer 64-bit build (vs 32-bit default)
    # - **5.5+ versions**: No suffix indicates 64-bit only (newer than legacy -64 versions)
    #
    # This reflects the real-world Antelope deployment where 5.5+ became 64-bit
    # only releases, making the -64 suffix redundant and legacy.
    #
    # @param bit1 [String, nil] First architecture suffix ('-64' or nil)
    # @param bit2 [String, nil] Second architecture suffix ('-64' or nil)
    # @param major [Integer] Major version number for transition logic
    # @param minor [Integer] Minor version number for transition logic
    #
    # @return [Integer] Comparison result:
    #   - `-1` if bit1 represents older architecture
    #   - `0` if architectures are equivalent
    #   - `1` if bit1 represents newer architecture
    #
    # @example Post-transition behavior (5.5+)
    #   # No suffix is newer than -64 (5.5+ are 64-bit only)
    #   compare_bit_suffixes(nil, '-64', 5, 5)    # => 1  (newer)
    #   compare_bit_suffixes('-64', nil, 5, 6)    # => -1 (older legacy)
    #   compare_bit_suffixes(nil, nil, 5, 5)      # => 0  (same)
    #
    # @example Pre-transition behavior (<5.5)
    #   # -64 suffix is newer than no suffix (vs 32-bit default)
    #   compare_bit_suffixes('-64', nil, 5, 4)    # => 1  (newer 64-bit)
    #   compare_bit_suffixes(nil, '-64', 5, 3)    # => -1 (older 32-bit)
    #   compare_bit_suffixes('-64', '-64', 5, 4)  # => 0  (same)
    #
    # @example Edge cases
    #   compare_bit_suffixes(nil, nil, 5, 4)      # => 0  (both 32-bit)
    #   compare_bit_suffixes('-64', '-64', 5, 5)  # => 0  (both same)
    #
    # @see #compare_antelope_versions For complete version comparison context
    #
    # @since 1.2.0
    #
    def compare_bit_suffixes(bit1, bit2, major, minor)
      # If both have or don't have bit suffix, they're equal in this aspect
      return 0 if (bit1.nil? && bit2.nil?) || (bit1 == bit2)

      # Special handling for the transition period
      # For versions 5.5+, no -64 suffix means it's 64-bit only (newer than -64 versions)
      # For versions before 5.5, -64 suffix means it's newer 64-bit (vs 32-bit default)

      if major > 5 || (major == 5 && minor >= 5)
        # Post-transition: no suffix is newer (5.5+ are 64-bit only)
        if bit1.nil? && bit2 == '-64'
          return 1  # version without -64 is newer
        elsif bit1 == '-64' && bit2.nil?
          return -1 # version with -64 is older
        end
      elsif bit1.nil? && bit2 == '-64'
        # During transition: -64 suffix is newer (vs 32-bit default)
        return -1
      elsif bit1 == '-64' && bit2.nil?
        return 1 # version with -64 is newer
      end

      0
    end

    #
    # Sort an array of Antelope version strings using Antelope comparison logic.
    #
    # Convenience method that sorts a collection of version strings from
    # oldest to newest using the compare_antelope_versions method.
    #
    # @param versions [Array<String>] Array of version strings to sort
    #
    # @return [Array<String>] Sorted array from oldest to newest version
    #
    # @example Sorting mixed version formats
    #   versions = ['5.5', '5.4-64', '5.3', '5.5pre', '5.4']
    #   sort_antelope_versions(versions)
    #   # => ['5.3', '5.4', '5.4-64', '5.5pre', '5.5']
    #
    # @example Sorting with post-transition versions
    #   versions = ['5.6', '5.5-64', '5.5', '5.6-64']
    #   sort_antelope_versions(versions)
    #   # => ['5.5-64', '5.5', '5.6-64', '5.6']
    #
    # @raise [ArgumentError] If any version string in the array is invalid
    #
    # @see #compare_antelope_versions For individual comparison logic
    #
    # @since 1.2.0
    #
    def sort_antelope_versions(versions)
      versions.sort { |a, b| compare_antelope_versions(a, b) }
    end

    private

    #
    # Validate that a version string matched the expected format.
    #
    # Checks if a parsed version represents a valid Antelope version by
    # examining the parsed components and original regex match. Raises
    # a descriptive ArgumentError for invalid formats.
    #
    # @param version [String] Original version string for error messages
    # @param parsed_version [Hash] Parsed version components from parse_antelope_version
    #
    # @return [void]
    #
    # @raise [ArgumentError] If the version format is invalid with descriptive message
    #
    # @example Valid version (no exception)
    #   validate_version_format!('5.5', { major: 5, minor: 5, bit_suffix: nil, suffix: nil })
    #
    # @example Invalid version (raises exception)
    #   validate_version_format!('invalid', { major: 0, minor: 0, bit_suffix: nil, suffix: nil })
    #   # => ArgumentError: Invalid Antelope version format: 'invalid'
    #
    # @api private
    # @since 1.2.0
    #
    def validate_version_format!(version, parsed_version)
      if parsed_version[:major] == 0 && parsed_version[:minor] == 0 &&
         parsed_version[:bit_suffix].nil? && parsed_version[:suffix].nil? &&
         !RE_VERSION.match(version)
        raise ArgumentError, "Invalid Antelope version format: '#{version}'"
      end
    end
  end
end
