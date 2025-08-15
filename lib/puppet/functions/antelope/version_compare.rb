# frozen_string_literal: true

# Compares two Antelope version strings according to Antelope's special versioning rules.
#
# This function handles Antelope's non-standard version comparison requirements:
# 1. During the 32-bit to 64-bit transition, versions like "5.1-64" should be
#    compared properly against later versions like "5.5"
# 2. Pre/post suffixes: "4.9pre" < "4.9" < "4.9post" < "4.10"
#
# @param version1 [String] First version to compare
# @param version2 [String] Second version to compare
# @return [Integer] -1 if version1 < version2, 0 if equal, 1 if version1 > version2
#
# @example Comparing basic versions
#   antelope_version_compare('5.1', '5.2') #=> -1
#
# @example Comparing 64-bit transition versions
#   antelope_version_compare('5.1-64', '5.5') #=> -1
#   antelope_version_compare('5.5', '5.1-64') #=> 1
#
# @example Comparing pre/post versions
#   antelope_version_compare('4.9pre', '4.9') #=> -1
#   antelope_version_compare('4.9', '4.9post') #=> -1
#   antelope_version_compare('4.9post', '4.10') #=> -1
Puppet::Functions.create_function(:'antelope::version_compare') do
  dispatch :compare do
    param 'String', :version1
    param 'String', :version2
  end

  def compare(version1, version2)
    return 0 if version1 == version2

    # Parse both versions using the same regex pattern as the existing Facter utility
    parsed1 = parse_antelope_version(version1)
    parsed2 = parse_antelope_version(version2)

    # Compare major version
    major_cmp = parsed1[:major] <=> parsed2[:major]
    return major_cmp unless major_cmp.zero?

    # Compare minor version
    minor_cmp = parsed1[:minor] <=> parsed2[:minor]
    return minor_cmp unless minor_cmp.zero?

    # Handle 64-bit suffix comparison
    # During transition: 32-bit (no suffix) < 64-bit (-64)
    # Post-transition: no suffix means 64-bit only, so it's newer than -64
    bit_cmp = compare_bit_suffixes(parsed1[:bit_suffix], parsed2[:bit_suffix],
                                   parsed1[:major], parsed1[:minor])
    return bit_cmp unless bit_cmp.zero?

    # Handle pre/post/p suffixes
    suffix_cmp = compare_suffixes(parsed1[:suffix], parsed2[:suffix])
    suffix_cmp
  end

  private

  # Parse an Antelope version string into components using the same regex as existing code
  def parse_antelope_version(version)
    # Use the same regex pattern as Facter::Util::Antelope::RE_VERSION
    # Pattern: ^(\d+)\.(\d+)(-64)?(pre|post|p)?$
    match = version.match(%r{^(\d+)\.(\d+)(-64)?(pre|post|p)?$})

    raise ArgumentError, "Invalid Antelope version format: #{version}" unless match

    {
      major: match[1].to_i,
      minor: match[2].to_i,
      bit_suffix: match[3], # '-64' or nil
      suffix: match[4]      # 'pre', 'post', 'p', or nil
    }
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
      return 1   # version with -64 is newer
    end

    0
  end
end
