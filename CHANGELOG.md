# Changelog

All notable changes to this project will be documented in this file.

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
