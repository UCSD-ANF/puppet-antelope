# @summary INTERNAL TEST CLASS - DO NOT USE
#
# @api private
#
# @deprecated This class is for internal testing purposes only and may be
#   removed or changed without notice. It is not part of the public API.
#
# WARNING: This is an internal test class used exclusively for validating the
# antelope::version_compare function during development and testing. It should
# never be included in production manifests or used by end users.
#
# This class exists solely to provide a testable Puppet context for the
# antelope::version_compare function. It performs various version comparison
# operations to ensure the function behaves correctly across different
# version formats and edge cases, including:
# - Basic version comparisons
# - 64-bit suffix handling
# - Pre/post release suffix logic
#
# DO NOT USE THIS CLASS:
# - This is not part of the module's public API
# - It may be removed or modified without notice
# - It is not supported for production use
# - It exists only for internal testing purposes
#
# If you need version comparison functionality, use the antelope::version_compare
# function directly in your manifests.
#
# @example DO NOT DO THIS - This class should never be included
#   include antelope::test_version_compare  # WRONG - DO NOT DO THIS
#
# @example Instead, use the function directly
#   if antelope::version_compare('5.5', '5.2-64') > 0 {
#     # Version 5.5 is newer than 5.2-64
#   }
#
class antelope::test_version_compare {
  # Test basic version comparison
  $result1 = antelope::version_compare('5.4', '5.5')

  # Test with 64-bit suffix
  $result2 = antelope::version_compare('5.4-64', '5.5')

  # Test with pre/post suffixes
  $result3 = antelope::version_compare('5.5pre', '5.5')

  # Use results in conditional logic to ensure they work
  if $result1 < 0 {
    notify { 'version_compare_test_1_passed': }
  }

  if $result2 < 0 {
    notify { 'version_compare_test_2_passed': }
  }

  if $result3 < 0 {
    notify { 'version_compare_test_3_passed': }
  }
}
