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

module Antelope
  module VersionUtils
    # Regular expression for parsing Antelope version strings
    RE_VERSION = %r{^(\d+)\.(\d+)(-64)?(pre|post|p)?$}.freeze

    # Compare two Antelope versions using Antelope-specific rules
    # Returns: -1 if version_a < version_b, 0 if equal, 1 if version_a > version_b
    # Raises ArgumentError for invalid version formats
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

    # Parse an Antelope version string into components
    # Returns a hash with :major, :minor, :bit_suffix, and :suffix keys
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

    # Compare pre/post/p suffixes according to Antelope rules
    # Order: pre < (no suffix) < post/p
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

    # Compare bit suffixes for the 32-bit to 64-bit transition
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

    # Sort an array of versions using Antelope comparison logic
    def sort_antelope_versions(versions)
      versions.sort { |a, b| compare_antelope_versions(a, b) }
    end

    private

    # Validate that a version string matched the expected format
    def validate_version_format!(version, parsed_version)
      if parsed_version[:major] == 0 && parsed_version[:minor] == 0 &&
         parsed_version[:bit_suffix].nil? && parsed_version[:suffix].nil? &&
         !RE_VERSION.match(version)
        raise ArgumentError, "Invalid Antelope version format: '#{version}'"
      end
    end
  end
end
