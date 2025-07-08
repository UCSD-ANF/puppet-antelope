# Changelog

All notable changes to this project will be documented in this file.

## Release 3.1.1 - 2025-07-08

**Bug Fixes**
- Fixed `pick()` function logic errors that caused runtime failures with undefined facts
- Fixed `pick($facts['antelope_services'], '')` to properly handle undefined facts
- Fixed `pick($facts['antelope_latest_version'], '5.15')` to use proper fallback value

**Code Quality**
- Replaced `lookup()` calls with direct class parameter references to eliminate lookup_in_parameter warnings
- Fixed all puppet-lint warnings (indentation, style, documentation)
- Fixed all rubocop warnings (Ruby code style, indentation, constant freezing)
- Removed trailing whitespace and added proper final newlines in spec files
- Fixed inconsistent indentation throughout codebase

**Development**
- Established semantic commit workflow with git commit message template
- Updated CONTRIBUTING.md with semantic commit guidelines
- Added Development section to README.md with commit template setup
- All PDK validation checks now pass with no warnings

## Release 3.1.0 - 2025-07-08

**Puppet 7.34.x Compatibility**
- Fixed all deprecations for full Puppet 7.34.x compatibility
- Modernized Facter API: Replaced deprecated Facter 2.x/3.x API with modern Facter 4+ structured facts
- Replaced deprecated `template()` function calls with modern `epp()` function
- Created new EPP templates: S99antelope.epp, license.pf.epp, site.pf.epp, antelope_sync.epp
- Fixed deprecated function calls: `split()` → `String.split()`, `flatten()` → `Array.flatten()`, `empty()` → `!= []`
- Updated include syntax from `include ::class` to `include class`
- Fixed parameter ordering issues (optional parameters before required parameters)
- Replaced legacy facts: `$facts['fqdn']` → `$facts['networking']['fqdn']`
- Fixed Ruby style issues and modernized code

**Testing**
- Fixed all unit tests for modernized Facter API structure
- All 763 unit tests passing with 0 failures
- Fixed EPP template handling for undef values in ensure=absent scenarios
- Fixed symbol vs string mismatch in antelope_latest facts

**Code Quality**
- Replaced deprecated `notice()` function with `notify` resource
- Fixed Ruby code style issues in MCollective agent
- Modernized Ruby methods and used safe navigation operators

## Release 3.0.0 - 2025-07-08

**BREAKING CHANGES**
- Removed deprecated PHP functionality (manifests/php.pp, templates/php.erb)
- PHP support is no longer available in modern Antelope versions
- Removed PHP configuration from data/common.yaml

**Code Quality**
- Removed legacy `validate_*` function calls in favor of modern Puppet data types
- Removed redundant `validate_bool()`, `validate_re()`, and `is_integer()` checks
- Replaced `is_array()` with modern `=~ Array` syntax
- Modernized global variable references (`$::facts` → `$facts`, removed `::` prefixes)
- Fixed duplicate pry gem dependency in Gemfile
- Fixed antelope_latest_version fact to be string for proper type validation

**Testing**
- Added comprehensive test coverage for `rtsystemdir` and `service_fact` classes
- Improved test coverage from 33.82% to 42.03%
- All 764 tests pass with modern Puppet versions
- Enhanced test environment compatibility

**Migration Guide**
- Remove any references to `antelope::php` class from your Puppet manifests
- PHP extensions for Antelope are no longer supported in this module

## Release 2.1.0 - 2025-07-07

**Features**
- Added support for Antelope 5.15 (latest version)
- Updated supported Antelope versions from 5.9 through 5.15
- Removed support for older Antelope versions (5.7, 5.8)
- Updated Python support to 3.12.3 (shipped with Antelope 5.15)
- Updated Perl support to 5.38.2 (shipped with Antelope 5.15)
- Added OS-specific configuration for RedHat 8/9 and Ubuntu (systemd service provider)
- Updated macOS support to require macOS 12 (Monterey) and higher for M-series compatibility

**Technical Changes**
- Updated default facts for testing with modern Antelope versions
- Enhanced OS support matrix for Antelope 5.15 requirements
- Maintained backward compatibility with Antelope versions 5.9+

## Release 2.0.0 - 2025-07-07

**BREAKING CHANGES**
- Minimum Puppet version increased from 4.10.0 to 6.0.0
- Removed support for CentOS/RHEL 6 and old macOS versions
- Development environment now requires Ruby 3.0+

**Features**
- Updated Puppet support to 6.0-9.0 (modern Puppet versions)
- Added support for Rocky Linux 8/9 and AlmaLinux 8/9
- Added support for Ubuntu 20.04, 22.04, and 24.04 LTS
- Updated macOS support to modern versions (11+)
- Replaced Travis CI with GitHub Actions for CI/CD
- Updated GitLab CI and AppVeyor for modern Ruby versions
- Added devcontainer with official PDK image for consistent development
- Added community standards files (CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md)
- Added GitHub issue templates and PR template
- Updated dependencies to support stdlib/concat up to 10.x
- Enhanced .gitignore for modern development tools
- Updated RuboCop configuration for Ruby 3.0+
- Added VS Code extensions configuration
- Updated Ruby version from 2.4.3 to 3.2.0
- Added comprehensive modernization documentation

**Technical Changes**
- Ran `pdk update` to sync with PDK 3.4.0 templates
- Updated Gemfile with modern dependency management
- Fixed duplicate gem dependencies
- Enhanced development workflow with modern tooling

**Migration Guide**
See MODERNIZATION.md for detailed migration instructions and breaking changes.

## Release 1.1.9 and earlier

Previous releases supported Puppet 4.10+ and older operating systems.
