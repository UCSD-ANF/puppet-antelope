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
4. Configure git commit template: `git config commit.template .gitmessage`

### Git Commit Template

This repository uses [Conventional Commits](https://www.conventionalcommits.org/) for consistent commit formatting. After cloning, configure the git commit template:

```bash
git config commit.template .gitmessage
```

This will provide a helpful template when creating commits with the proper semantic format:
- **feat**: new feature
- **fix**: bug fix
- **docs**: documentation changes
- **style**: formatting, linting fixes; no code changes
- **refactor**: code refactoring without functional changes
- **test**: adding/updating tests
- **chore**: build tasks, dependency updates, etc.

Example: `feat(manifests): add support for Antelope 5.16`

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
6. Commit your changes using semantic commit format (`git commit -m 'feat(manifests): add some feature'`)
7. Push to the branch (`git push origin feature/my-new-feature`)
8. Create a Pull Request

Please use the semantic commit format for all commits. The git commit template will help guide you.

## Reporting Issues

Please use the GitHub issue tracker to report bugs or request features.

## Code of Conduct

Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.