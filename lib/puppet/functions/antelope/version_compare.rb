# frozen_string_literal: true

require 'antelope/version_utils'

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
  include Antelope::VersionUtils

  dispatch :compare do
    param 'String', :version1
    param 'String', :version2
  end

  def compare(version1, version2)
    # Use the shared utility method
    compare_antelope_versions(version1, version2)
  end
end
