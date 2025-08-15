# Changelog

All notable changes to this project will be documented in this file.

## Release 4.1.3 (2025-08-15) - Puppet 8.10.0 Compatibility Fix

**Critical Bugfixes**
- **Puppet 8.10.0 Compatibility**: Resolved "Syntax error at ':'" that was preventing the `antelope::version_compare` function from working with Puppet 8.10.0
  - Fixed require path from `require 'antelope/version_utils'` to `require_relative '../../../antelope/version_utils'`
  - Removed invalid `include Antelope::VersionUtils` statement not compatible with Puppet 4+ functions
  - Fixed module usage by extending `Antelope::VersionUtils` and calling methods directly
- **Testing**: Added comprehensive integration test (`version_compare_puppet_integration_spec.rb`) that validates the function works correctly within Puppet code
- **Test Coverage**: All 241 tests now pass including 19 version comparison tests and 5 integration tests

**Technical Details**
- The shared utility module `Antelope::VersionUtils` is now properly extended rather than called as a class method
- Integration test ensures the function loads without syntax errors and validates file structure corrections
- Function now parses and loads correctly with Puppet 8.10.0 while maintaining full backward compatibility

**Impact**
- **Severity**: Critical - Function was non-functional with Puppet 8.10.0 due to syntax errors
- **Scope**: Single function fix with comprehensive testing validation
- **Testing**: Full test suite verified and passing with new integration tests
- **Compatibility**: Maintains full backward compatibility while adding Puppet 8.10.0 support

## Release 4.1.1 (2025-08-15) - Emergency Patch

**Critical Bugfixes**
- Fixed critical syntax error in `lib/antelope/version_utils.rb` that was preventing module loading
- Resolved duplicate `end` statement in nested module structure that blocked 25 test cases
- Restored full test suite functionality (237/237 tests now passing)
- Fixed shared utility architecture that provides version comparison synchronization

**Impact**
- **Severity**: Critical - Module was non-functional due to Ruby syntax error
- **Scope**: Single file fix with immediate resolution
- **Testing**: Full test suite verified and passing
- **Compatibility**: No breaking changes, pure syntax correction

## Release

**Features**

**Bugfixes**

**Known Issues**
