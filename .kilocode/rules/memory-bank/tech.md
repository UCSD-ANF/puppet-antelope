# Technical Overview

## Core Technologies

### Puppet Infrastructure
- **Puppet Version Support**: 7.0.0 through 8.x
- **PDK Version**: 3.4.0 (Puppet Development Kit)
- **Hiera Version**: 5.x with YAML backend
- **Module Structure**: Modern Puppet 4+ patterns with typed parameters

### Programming Languages
- **Puppet DSL**: Primary configuration language
- **Ruby**: 2.4.5 through 2.5.7 for Facter facts and testing
- **ERB Templates**: Configuration file generation
- **YAML**: Hiera data and configuration

## Dependencies

### Required Puppet Modules
- **puppetlabs/stdlib**: >= 6.0.0 < 7.0.0
  - Standard library functions and types
- **puppetlabs/concat**: > 6.0.0 < 7.0.0
  - File fragment assembly for service facts

### System Dependencies
- **rsync**: For synchronization functionality
- **ssh**: For secure synchronization transport
- **MCollective**: Optional remote management framework

## Development Tools

### Build and Test Framework
- **PDK (Puppet Development Kit)**: Primary development tool
- **Bundler**: Ruby dependency management
- **RSpec**: Unit testing framework
- **puppet-litmus**: Acceptance testing (if available)

### Code Quality Tools
- **RuboCop**: Ruby code style enforcement
- **puppet-lint**: Puppet-specific linting
- **puppet-syntax**: Puppet syntax validation
- **metadata-json-lint**: Metadata validation

### Version Control and Documentation
- **Git**: Version control with GitHub/GitLab hosting
- **GitHub CLI**: Automated GitHub release creation
- **GitHub Changelog Generator**: Automated changelog generation
- **puppet-strings**: Documentation generation (if available)

## Development Setup

### Local Environment Requirements
```bash
# Install PDK
# Install Ruby 2.4.5+ or 2.5.7+
# Clone repository
bundle install --without system_tests
```

### Common Development Commands
```bash
# Run all validations
pdk validate

# Run unit tests
pdk test unit

# Syntax check
bundle exec rake syntax

# Linting
bundle exec rake lint

# Full test suite
bundle exec rake

# GitHub release automation
pdk bundle exec rake ghrelease:preview[patch]
pdk bundle exec rake ghrelease:validate
pdk bundle exec rake ghrelease:create[minor,"feat: new feature"]
```

## CI/CD Pipeline

### Continuous Integration Platforms
- **Travis CI**: Linux testing with Ruby 2.4.5/2.5.7, Puppet 5.x/6.x matrix
- **GitLab CI**: Containerized testing with Ruby 2.5.7, Puppet 6.x
- **AppVeyor**: Windows compatibility testing

### Test Matrix
- **Ruby Versions**: 2.4.5, 2.5.7
- **Puppet Versions**: ~> 5.0, ~> 6.0
- **Platforms**: Linux (primary), Windows (compatibility)

### Pipeline Stages
1. **Static Analysis**: syntax, lint, metadata_lint, rubocop
2. **Unit Testing**: parallel_spec execution
3. **Deployment**: Automated forge deployment on version tags

## Operating System Support

### Supported Platforms
- **RedHat/CentOS**: 6, 7
- **Darwin (macOS)**: 14, 15, 16

### OS-Specific Configuration
- **Hiera Hierarchy**: OS-family specific parameter resolution
- **Service Providers**: Platform-specific service management
- **Path Conventions**: Filesystem layout variations
- **Permission Models**: Different user/group handling

## Testing Strategy

### Unit Testing
- **Framework**: RSpec with Puppet helpers
- **Coverage**: Classes, defined types, facts, custom functions, and shared utilities
- **Mock Data**: Comprehensive fact fixtures in [`spec/default_facts.yml`](spec/default_facts.yml)
- **Shared Testing**: Comprehensive test suite for `Antelope::VersionUtils` with 87 test cases

### Advanced Testing Patterns
- **Cross-Validation Testing**: Ensures Puppet functions and Facter utilities use identical logic
- **Integration Testing**: Tests shared utility module in both Puppet and Facter contexts
- **Version Comparison Coverage**: Exhaustive testing of 64-bit transition and suffix logic
- **Enterprise Test Documentation**: Detailed test descriptions with expected behaviors

### Test Configuration
- **Spec Helper**: Custom configuration in [`spec/spec_helper_local.rb`](spec/spec_helper_local.rb)
- **Fixtures**: `.fixtures.yml` for dependency management
- **Mock Facts**: Version-specific Antelope facts for testing
- **Shared Utility Tests**: Dedicated test suite in [`spec/unit/antelope/version_utils_spec.rb`](spec/unit/antelope/version_utils_spec.rb)

### Quality Assurance
- **Syntax Validation**: puppet-syntax for DSL correctness
- **Style Enforcement**: puppet-lint with module-specific rules
- **Ruby Standards**: RuboCop with relaxed metrics for Puppet modules

## Configuration Management

### Hiera Integration
- **Version**: Hiera 5 with YAML backend
- **Hierarchy**: OS-specific → OS-family → common
- **Data Directory**: [`data/`](data/) with OS-specific overrides
- **Configuration**: [`hiera.yaml`](hiera.yaml) with path-based lookups

### Parameter Management
- **Default Values**: Centralized in [`data/common.yaml`](data/common.yaml)
- **OS Overrides**: Platform-specific values in [`data/os/`](data/os/)
- **Type Safety**: Custom Puppet data types for validation

## Module Architecture Patterns

### Resource Management
- **Autorequires**: Automatic dependency resolution
- **Service Providers**: Abstracted platform handling
- **File Templates**: ERB-based configuration generation
- **Concat Fragments**: Modular fact file assembly

### Custom Extensions
- **Data Types**: Strongly typed parameters in [`types/`](types/)
- **Facter Facts**: System discovery in [`lib/facter/`](lib/facter/)
- **Utility Functions**: Reusable logic in [`lib/facter/util/`](lib/facter/util/)
- **Shared Utilities**: Cross-component logic in [`lib/antelope/`](lib/antelope/)

### Shared Utility Pattern
- **Module Design**: `Antelope::VersionUtils` as includable module
- **Thread Safety**: Safe for concurrent use in Puppet and Facter
- **Consistent API**: Same method signatures across components
- **Error Handling**: Comprehensive validation with descriptive messages
- **Documentation**: Enterprise-grade YARD documentation with examples

### Development Standards
- **Version Comparison**: All version logic must use `Antelope::VersionUtils`
- **Documentation**: YARD documentation required for new utilities
- **Testing**: Cross-validation testing for shared components
- **Compatibility**: Maintain backward compatibility in public APIs

## Development Constraints

### Puppet Version Compatibility
- **Minimum**: Puppet 4.10.0 for modern data types
- **Maximum**: Puppet 6.x (not yet 7.x compatible)
- **Features**: Uses Puppet 4+ typed parameters and Hiera 5

### Ruby Compatibility
- **Target Version**: Ruby 2.1+ (RuboCop configuration)
- **Testing Versions**: 2.4.5, 2.5.7
- **Platform Support**: POSIX systems primarily

### Licensing and Distribution
- **License**: BSD-2-Clause
- **Distribution**: Puppet Forge compatible
- **Versioning**: Semantic versioning (SemVer)

## GitHub Release Automation

### Release Management Tools
- **`ghrelease:create[type,message]`** - Complete GitHub release automation with semantic versioning
- **`ghrelease:preview[type]`** - Preview next version increment without making changes
- **`ghrelease:validate`** - Comprehensive validation of release prerequisites
- **`ghrelease`** - Convenient alias for `ghrelease:create`

### Automation Features
- **Semantic Versioning**: Automatic version increment (major/minor/patch) in metadata.json
- **Safety Validation**: Multi-layer validation (git status, PDK, GitHub CLI availability)
- **Flexible Input**: Multiple commit message methods (CLI parameter, environment variable, interactive editor)
- **Professional Output**: Auto-generated release notes with technical details and installation instructions
- **Workflow Integration**: Complements existing puppet-blacksmith module:release for Puppet Forge publishing

### Dependencies
- **`semantic` gem**: For semantic versioning operations (added to Gemfile)
- **GitHub CLI (`gh`)**: For creating GitHub releases (external dependency)
- **PDK environment**: All operations run within PDK bundle context

### Usage Patterns
```bash
# Preview next version
pdk bundle exec rake ghrelease:preview[minor]

# Validate release prerequisites
pdk bundle exec rake ghrelease:validate

# Create releases with different increment types
pdk bundle exec rake ghrelease:create[patch,"fix: resolve template issue"]
pdk bundle exec rake ghrelease:create[minor,"feat: add new configuration"]
pdk bundle exec rake ghrelease:create[major,"feat!: breaking API change"]

# Interactive commit message via editor
pdk bundle exec rake ghrelease:create[patch]
```

### Safety Features
- **Clean Working Directory**: Validates no uncommitted changes before release
- **PDK Validation**: Runs full PDK validation suite before proceeding
- **GitHub CLI Check**: Ensures GitHub CLI is installed and authenticated
- **Remote Configuration**: Validates git remote is properly configured
- **Error Handling**: Comprehensive error checking with descriptive messages

### Integration with Existing Workflow
- **Puppet Forge**: Use `module:release` for Puppet Forge publishing
- **GitHub Releases**: Use `ghrelease:create` for GitHub releases
- **Combined Workflow**: Both tools can be used together for complete release automation