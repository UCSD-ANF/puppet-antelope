# Contributing

We welcome contributions to the Antelope Puppet module! This document provides guidelines for contributing to the project.

## Development Setup

### Using the devcontainer (Recommended)

1. Clone the repository
2. Open in VS Code
3. When prompted, choose "Reopen in Container"
4. The development environment will be automatically configured

### Manual setup

1. Install Ruby 3.0+ and Bundler
2. Install PDK: `gem install pdk`
3. Install dependencies: `bundle install`

## Testing

Before submitting a pull request, please run the full test suite:

```bash
# Static analysis
bundle exec rake lint
bundle exec rake syntax
bundle exec rake rubocop

# Unit tests
bundle exec rake spec

# Integration tests (if applicable)
bundle exec rake beaker
```

## Code Style

- Follow the existing code style
- Use RuboCop for Ruby code linting
- Use puppet-lint for Puppet code linting
- Write tests for new functionality

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-new-feature`)
3. Make your changes
4. Add tests for your changes
5. Ensure all tests pass
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin feature/my-new-feature`)
8. Create a Pull Request

## Reporting Issues

Please use the GitHub issue tracker to report bugs or request features.

## Code of Conduct

Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.