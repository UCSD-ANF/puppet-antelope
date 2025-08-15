# Example demonstrating the antelope::version_compare function
#
# This example shows how to use the antelope::version_compare function
# for version-dependent configuration in Puppet manifests.

# Example 1: Conditional configuration based on version comparison
$current_version = '5.2'
$minimum_version = '5.1-64'

if antelope::version_compare($current_version, $minimum_version) >= 0 {
  notify { 'version_check':
    message => "Current version ${current_version} meets minimum requirement ${minimum_version}",
  }
} else {
  fail("Current version ${current_version} is older than required ${minimum_version}")
}

# Example 2: Selecting the latest version from an array
$available_versions = ['5.1', '5.1-64', '5.2', '4.9post', '5.5']

# Find the maximum version using reduce
$latest_version = $available_versions.reduce |$memo, $version| {
  if antelope::version_compare($version, $memo) > 0 {
    $version
  } else {
    $memo
  }
}

notify { 'latest_version':
  message => "Latest available version: ${latest_version}",
}

# Example 3: Sorting versions
$sorted_versions = $available_versions.sort |$a, $b| {
  antelope::version_compare($a, $b)
}

notify { 'sorted_versions':
  message => "Versions in order: ${sorted_versions.join(', ')}",
}

# Example 4: Version-specific resource management
case $current_version {
  /^4\./: {
    notify { 'v4_config': message => 'Using Antelope 4.x configuration' }
  }
  /^5\.[0-4]/: {
    notify { 'v5_early_config': message => 'Using early Antelope 5.x configuration' }
  }
  default: {
    if antelope::version_compare($current_version, '5.5') >= 0 {
      notify { 'v5_modern_config': message => 'Using modern Antelope 5.5+ configuration' }
    }
  }
}
