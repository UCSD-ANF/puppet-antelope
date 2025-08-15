# Contributing to puppet-antelope

Thank you for your interest in contributing to the puppet-antelope module! This document provides guidelines and instructions for developers.

## Development Environment Setup

### Prerequisites

- **PDK (Puppet Development Kit)**: Required for validation, testing, and module management
- **Ruby**: Version 2.4.5+ or 2.5.7+
- **Puppet**: Versions 4.10.0 through 8.x are supported
- **Git**: For version control

### Initial Setup

1. Fork the repository on GitHub/GitLab
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/puppet-antelope.git
   cd puppet-antelope
   ```
3. Install dependencies:
   ```bash
   bundle install --without system_tests
   ```
4. **Install pre-commit hooks** (recommended):
   ```bash
   ./hooks/install-hooks.sh
   ```

## Pre-commit Hooks

This repository includes pre-commit hooks that automatically run quality checks before each commit. These hooks help prevent syntax errors and maintain code quality standards.

### What the Pre-commit Hook Does

The pre-commit hook runs `pdk validate`, which performs:
- **Metadata validation**: Checks `metadata.json` syntax and style
- **Puppet manifest validation**: Syntax and style checking for `.pp` files  
- **Ruby code validation**: Syntax and style checking for Ruby files
- **YAML validation**: Syntax checking for YAML files

### Installing Pre-commit Hooks

**Recommended**: Use the provided installation script:
```bash
./hooks/install-hooks.sh
```

**Manual Installation**: Copy the hook directly:
```bash
cp hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Working with Pre-commit Hooks

- The hook will automatically run when you attempt to commit
- If validation fails, the commit will be blocked until issues are fixed
- To bypass the hook temporarily (not recommended): `git commit --no-verify`

Example output when validation passes:
```
Running PDK validation...
✓ All validations passed!
```

## Development Workflow

### Making Changes

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes
3. Run validation manually to catch issues early:
   ```bash
   pdk validate
   ```
4. Run tests:
   ```bash
   pdk test unit
   ```
5. Commit your changes (pre-commit hook will run automatically)
6. Push your branch and create a pull request

### Code Quality Standards

- **Puppet manifests**: Follow puppet-lint recommendations
- **Ruby code**: Follow RuboCop style guidelines (with project-specific exceptions)
- **Documentation**: Update documentation for new features or significant changes
- **Tests**: Include appropriate test coverage for new functionality

### Running Validations and Tests

```bash
# Run all validations (syntax, style, metadata)
pdk validate

# Run specific validators
pdk validate puppet
pdk validate ruby
pdk validate metadata

# Run unit tests  
pdk test unit

# Run all tests and validations
bundle exec rake
```

## Testing

The module uses RSpec for unit testing:
- Test files are located in `spec/`
- Run tests with `pdk test unit`
- Maintain test coverage for new functionality
- Use the shared facts in `spec/default_facts.yml` for consistent testing

## Documentation

- Update the README.md if adding new classes, parameters, or functionality
- Include inline documentation in Puppet manifests using puppet-strings format
- Update CHANGELOG.md following the established format
- For complex features, add examples in the `examples/` directory

## Submitting Changes

1. Ensure all validations pass (`pdk validate`)
2. Ensure all tests pass (`pdk test unit`)
3. Update documentation as needed
4. Submit a pull request with:
   - Clear description of changes
   - Reference to any related issues
   - Test results if applicable

## Module Architecture

This module follows modern Puppet 4+ patterns:
- **Hiera 5**: For parameter management and OS-specific overrides
- **Typed parameters**: Using custom data types in `types/`
- **Custom facts**: System discovery in `lib/facter/`
- **PDK structure**: Standard PDK-generated module layout

### Key Components

- **`manifests/init.pp`**: Main class for basic Antelope setup
- **`manifests/instance.pp`**: Defined type for Antelope service instances
- **`lib/facter/`**: Custom facts for Antelope version detection
- **`lib/antelope/`**: Shared utility modules for version comparison
- **`types/`**: Custom Puppet data types for parameter validation

## Getting Help

- Check existing issues on the project repository
- Review the README.md for usage examples
- Look at the `examples/` directory for configuration patterns
- For questions specific to UCSD-ANF usage, contact the maintainers

## Code of Conduct

- Be respectful and constructive in all interactions
- Focus on technical merit and project goals
- Welcome newcomers and help them get started
- Follow the project's established patterns and conventions

---

Thank you for contributing to puppet-antelope! Your contributions help maintain and improve critical infrastructure for seismic monitoring systems.