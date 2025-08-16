# GitHub Release Automation

This module includes a comprehensive Rake task for automating GitHub releases with semantic versioning.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Clean working directory (all changes committed)
- PDK environment with required gems

## Available Tasks

### `rake ghrelease:create[type,message]`

Creates a new GitHub release with automatic version increment.

**Parameters:**
- `type` (optional): Version increment type - `major`, `minor`, or `patch` (default: `patch`)
- `message` (optional): Commit message for the release

**Examples:**
```bash
# Create a patch release with interactive commit message
pdk bundle exec rake ghrelease:create

# Create a minor release with specific message
pdk bundle exec rake ghrelease:create[minor,"feat: add new feature for X"]

# Create a major release with specific message
pdk bundle exec rake ghrelease:create[major,"feat!: breaking change for Y"]
```

**What it does:**
1. Validates prerequisites (clean git status, PDK validation, GitHub CLI)
2. Increments version in `metadata.json` according to semantic versioning
3. Creates git commit with provided message
4. Creates git tag (e.g., `v4.1.5`)
5. Pushes commit and tag to remote repository
6. Creates GitHub release with auto-generated release notes

### `rake ghrelease:preview[type]`

Shows current version and previews the next version increment.

**Examples:**
```bash
# Preview next patch version (default)
pdk bundle exec rake ghrelease:preview

# Preview next minor version
pdk bundle exec rake ghrelease:preview[minor]

# Preview next major version  
pdk bundle exec rake ghrelease:preview[major]
```

### `rake ghrelease:validate`

Validates all release prerequisites without making changes.

**Checks:**
- Working directory is clean (no uncommitted changes)
- PDK validation passes
- GitHub CLI is available and authenticated
- Git remote is properly configured

### `rake ghrelease` (alias)

Shorthand for `ghrelease:create` with default parameters.

## Commit Message Formats

The task supports multiple ways to provide commit messages:

### 1. Command Line Parameter
```bash
pdk bundle exec rake ghrelease:create[patch,"fix: resolve issue with template loading"]
```

### 2. Environment Variable
```bash
export RELEASE_MESSAGE="feat: add new configuration option"
pdk bundle exec rake ghrelease:create
```

### 3. Interactive Editor
If no message is provided, the task opens your default editor (`$EDITOR` or nano) with a template:

```
# Enter your release commit message above this line
# Lines starting with # are ignored
# Format: type: description
# Examples:
#   feat: add new feature for X
#   fix: resolve issue with Y
#   docs: update documentation for Z
```

## Semantic Versioning

The task follows semantic versioning (SemVer) rules:

- **patch** (e.g., 4.1.4 → 4.1.5): Bug fixes, small improvements
- **minor** (e.g., 4.1.4 → 4.2.0): New features, backwards compatible
- **major** (e.g., 4.1.4 → 5.0.0): Breaking changes

## Release Notes Generation

The task automatically generates comprehensive release notes including:

- Release title derived from commit message
- Commit message description
- Technical details (version, date, validation status)
- Installation instructions
- Link to CHANGELOG

## Error Handling

The task includes comprehensive error checking:

- Validates version increment type
- Requires commit message
- Ensures clean working directory
- Runs PDK validation before release
- Checks GitHub CLI availability
- Verifies git remote configuration

## Integration with Existing Workflow

This task complements existing Puppet module release tools:

- **`rake module:release`** - Publishes to Puppet Forge (from puppet-blacksmith)
- **`rake ghrelease:create`** - Creates GitHub releases with semantic versioning

Both can be used together for complete release automation.

## Example Workflow

```bash
# 1. Validate everything is ready
pdk bundle exec rake ghrelease:validate

# 2. Preview the next version
pdk bundle exec rake ghrelease:preview[minor]

# 3. Create the GitHub release
pdk bundle exec rake ghrelease:create[minor,"feat: add support for Antelope 5.6"]

# 4. Optionally publish to Puppet Forge
pdk bundle exec rake module:release
```

## Dependencies

The following gems are required (already included in Gemfile):

- `semantic` - For semantic versioning operations
- `json` - For metadata.json manipulation  
- GitHub CLI - For creating releases (external dependency)