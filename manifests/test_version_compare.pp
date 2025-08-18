# Test class that uses the antelope::version_compare function
# This is used for integration testing to ensure the function works in real Puppet code
class test_version_compare {
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
