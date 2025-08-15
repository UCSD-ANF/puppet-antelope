# System Architecture

## Module Structure
The puppet-antelope module follows modern Puppet 4+ architecture patterns with a well-organized directory structure:

```
puppet-antelope/
├── manifests/           # Main Puppet classes and defined types
├── lib/facter/         # Custom Facter facts for system discovery
├── types/              # Custom Puppet data types
├── data/               # Hiera data with OS-specific overrides
├── templates/          # ERB templates for configuration files
├── files/              # Static files (MCollective agents, sync configs)
└── spec/               # RSpec tests for all components
```

## Core Classes and Relationships

### Primary Classes
- **[`antelope`](manifests/init.pp)** - Main singleton class that orchestrates the entire module
- **[`antelope::instance`](manifests/instance.pp)** - Manages individual Antelope service instances
- **[`antelope::sync`](manifests/sync.pp)** - Provides rsync-based synchronization from golden masters
- **[`antelope::php`](manifests/php.php)** - Enables Antelope PHP extensions
- **[`antelope::mco`](manifests/mco.pp)** - MCollective integration for remote management

### Supporting Classes
- **[`antelope::service_fact`](manifests/service_fact.pp)** - Manages the antelope_services fact using concat
- **[`antelope::rtsystemdir`](manifests/rtsystemdir.pp)** - Manages permissions in real-time system directories

### Defined Types
- **[`antelope::versioned_site_pf`](manifests/versioned_site_pf.pp)** - Version-specific site.pf configuration
- **[`antelope::versioned_license_pf`](manifests/versioned_license_pf.pp)** - Version-specific license.pf management

## Custom Data Types

The module defines sophisticated custom types in [`types/`](types/):
- **[`Antelope::User`](types/user.pp)** - User specification (string or UID)
- **[`Antelope::Group`](types/group.pp)** - Group specification (string or GID)
- **[`Antelope::Dirs`](types/dirs.pp)** - Directory paths (single or array)
- **[`Antelope::Version`](types/version.pp)** - Antelope version pattern matching
- **[`Antelope::Instances`](types/instances.pp)** - Complex hash structure for multi-instance configuration

## Facter Facts System

### Core Discovery Facts
Located in [`lib/facter/`](lib/facter/):
- **[`antelope_versions`](lib/facter/antelope_versions.rb)** - All installed Antelope versions
- **[`antelope_latest_version`](lib/facter/antelope_latest.rb)** - Newest version detection
- **[`antelope_contrib_basedir`](lib/facter/antelope_contrib_basedir.rb)** - Contrib directory location mapping

### Utility Library
- **[`lib/facter/util/antelope.rb`](lib/facter/util/antelope.rb)** - Core utility functions for version sorting, system interaction
- **[`lib/antelope/version_utils.rb`](lib/antelope/version_utils.rb)** - Shared version comparison utilities used by both Puppet and Facter

## Shared Utility Architecture

### Version Comparison Synchronization
As of version 1.2.0, the module implements a sophisticated shared utility pattern for version comparison:

- **[`Antelope::VersionUtils`](lib/antelope/version_utils.rb)** - Centralized version comparison logic
  - Handles 64-bit architecture transition at version 5.5
  - Supports pre/post/p release suffix ordering
  - Provides thread-safe implementation for both Puppet and Facter contexts
  - Comprehensive YARD documentation with 393 lines of enterprise-grade code

### Cross-Component Integration
- **[`antelope::version_compare`](lib/puppet/functions/antelope/version_compare.rb)** - Puppet function using shared logic
- **[`Facter::Util::Antelope`](lib/facter/util/antelope.rb)** - Facter utility extending shared module
- **Consistent API**: Both components use identical `compare_antelope_versions` method
- **Bug Fixes**: Resolved bit suffix comparison logic affecting version ordering

## Key Design Patterns

### 1. Multi-Version Support Architecture
- Base directory: `/opt/antelope`
- Version-specific paths: `/opt/antelope/5.x/`
- Concurrent version management through version-specific resources
- Dynamic version detection via Facter facts

### 2. Instance Management Pattern
- Singleton mode: Single default instance via `dirs` parameter
- Multi-instance mode: Hash-based configuration via `instances` parameter  
- Instance isolation through user/group separation
- Service lifecycle management per instance

### 3. Configuration Management Strategy
- Template-driven configuration for site.pf and license.pf
- Parameter file management with version awareness
- Real-time system directory permission control
- Selective configuration replacement policies

### 4. Service Integration Architecture
- Init script generation from templates
- Service provider abstraction (systemd/sysvinit)
- Dependency management through autorequires
- Service subscription and notification patterns

## Critical Implementation Paths

### System Discovery Flow
1. **[`Facter::Util::Antelope.versions`](lib/facter/util/antelope.rb:140)** - Scans `/opt/antelope` for valid installations
2. **Version sorting** - Uses shared `Antelope::VersionUtils.sort_antelope_versions` method
3. **Facts generation** - Creates both string and array format facts for compatibility

### Version Comparison Architecture
1. **Shared Logic**: `Antelope::VersionUtils` provides consistent version comparison
2. **64-bit Transition**: Handles complex logic where 5.5+ versions treat no suffix as newer
3. **Suffix Ordering**: Implements `pre < release < post/p` ordering rules
4. **Format Validation**: Strict regex validation with descriptive error messages
5. **Cross-Validation**: 87 comprehensive test cases ensuring Puppet/Facter consistency

### Instance Deployment Flow
1. **Parameter validation** - Ensures exclusive use of `dirs` vs `instances`
2. **Resource hash generation** - Transforms parameters into resource declarations
3. **Service creation** - Generates init scripts via [`templates/S99antelope.erb`](templates/S99antelope.erb)
4. **Directory management** - Configures rtexec.pf permissions through `antelope::rtsystemdir`

### Synchronization Architecture
- **[`antelope::sync`](manifests/sync.pp)** - Wrapper around rsync for golden master deployment
- **Include/exclude lists** - Fine-grained control via [`files/sync/`](files/sync/)
- **Multi-tree support** - Synchronizes both base Antelope and site-specific trees
- **Protocol flexibility** - Supports both rsync:// and SSH transport

## Component Relationships

### Data Flow Architecture
```
Facter Facts → Hiera Data → Main Class → Instance Resources → Service Management
     ↓              ↓           ↓              ↓                    ↓
System Discovery → Config → Orchestration → Deployment → Runtime Management
```

### Dependency Chains
- **User resources** → **Service resources** (autorequire pattern)
- **Directory resources** → **Permission management**
- **Template generation** → **Service notification**
- **Fact collection** → **Resource parameter resolution**

## Integration Points

### External Dependencies
- **puppetlabs/stdlib** - Standard library functions and types
- **puppetlabs/concat** - Service fact file assembly
- **System packages** - rsync, ssh for synchronization
- **MCollective framework** - Remote management capabilities

### OS Abstraction
- **Hiera hierarchy** - OS-specific parameter resolution via [`data/os/`](data/os/)
- **Service providers** - Platform-specific service management
- **Path conventions** - Filesystem layout adaptation per OS
- **Permission models** - User/group handling variations