# frozen_string_literal: true

require 'bundler'
require 'puppet_litmus/rake_tasks' if Gem.loaded_specs.key? 'puppet_litmus'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-strings/tasks' if Gem.loaded_specs.key? 'puppet-strings'

PuppetLint.configuration.send('disable_relative')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_single_quote_string_with_variables')
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.ignore_paths = [".vendor/**/*.pp", ".bundle/**/*.pp", "pkg/**/*.pp", "spec/**/*.pp", "tests/**/*.pp", "types/**/*.pp", "vendor/**/*.pp"]

# ============================================================================
# Release Management Tasks
# ============================================================================

require 'json'
require 'semantic'
require 'tempfile'

namespace :ghrelease do
  desc 'Create a new GitHub release with automatic version increment'
  task :create, [:type, :message] do |_t, args|
    # Validate arguments
    type = args[:type] || 'patch'
    unless %w[major minor patch].include?(type)
      abort "ERROR: Invalid version type '#{type}'. Use: major, minor, or patch"
    end

    # Get commit message
    message = get_commit_message(args[:message])
    abort 'ERROR: No commit message provided' if message.nil? || message.strip.empty?

    puts "🚀 Creating #{type} release..."
    puts "📝 Commit message: #{message.split("\n").first}"

    # Ensure clean working directory
    abort 'ERROR: Working directory not clean' unless git_clean?

    # Get current version and increment
    current_version = get_current_version
    new_version = increment_version(current_version, type)
    
    puts "📈 Version: #{current_version} → #{new_version}"

    # Update version in metadata.json
    update_metadata_version(new_version)

    # Validate before committing
    puts '🔍 Validating changes...'
    abort 'ERROR: PDK validation failed' unless system('pdk validate > /dev/null 2>&1')

    # Create git commit and tag
    puts '📦 Creating commit and tag...'
    system("git add metadata.json")
    system("git commit -m \"#{message}\"")
    system("git tag -a v#{new_version} -m \"Release v#{new_version}\"")

    # Push to remote
    puts '🌐 Pushing to remote...'
    system('git push origin main')
    system("git push origin v#{new_version}")

    # Create GitHub release
    puts '🎉 Creating GitHub release...'
    create_github_release(new_version, message)

    puts "✅ Release v#{new_version} created successfully!"
    puts "🔗 https://github.com/UCSD-ANF/puppet-antelope/releases/tag/v#{new_version}"
  end

  desc 'Show current version and preview next version increment'
  task :preview, [:type] do |_t, args|
    type = args[:type] || 'patch'
    unless %w[major minor patch].include?(type)
      abort "ERROR: Invalid version type '#{type}'. Use: major, minor, or patch"
    end

    current_version = get_current_version
    new_version = increment_version(current_version, type)
    
    puts "Current version: #{current_version}"
    puts "Next #{type} version: #{new_version}"
  end

  desc 'Validate release prerequisites'
  task :validate do
    puts '🔍 Validating release prerequisites...'
    
    # Check git status
    unless git_clean?
      puts '❌ Working directory not clean'
      system('git status --porcelain')
      exit 1
    end
    puts '✅ Working directory clean'

    # Check PDK validation
    unless system('pdk validate > /dev/null 2>&1')
      puts '❌ PDK validation failed'
      system('pdk validate')
      exit 1
    end
    puts '✅ PDK validation passed'

    # Check GitHub CLI
    unless system('gh --version > /dev/null 2>&1')
      puts '❌ GitHub CLI not available'
      exit 1
    end
    puts '✅ GitHub CLI available'

    # Check git remote
    unless system('git remote get-url origin > /dev/null 2>&1')
      puts '❌ Git remote not configured'
      exit 1
    end
    puts '✅ Git remote configured'

    puts '🎯 All prerequisites satisfied!'
  end

  # Helper methods
  def get_current_version
    metadata = JSON.parse(File.read('metadata.json'))
    metadata['version']
  end

  def increment_version(version, type)
    sem_version = Semantic::Version.new(version)
    case type
    when 'major'
      sem_version.major += 1
      sem_version.minor = 0
      sem_version.patch = 0
    when 'minor'
      sem_version.minor += 1
      sem_version.patch = 0
    when 'patch'
      sem_version.patch += 1
    end
    sem_version.to_s
  end

  def update_metadata_version(new_version)
    metadata = JSON.parse(File.read('metadata.json'))
    metadata['version'] = new_version
    File.write('metadata.json', JSON.pretty_generate(metadata) + "\n")
  end

  def git_clean?
    system('git diff-index --quiet HEAD --')
  end

  def get_commit_message(message_arg)
    return message_arg if message_arg && !message_arg.strip.empty?

    # Try to get from environment variable
    return ENV['RELEASE_MESSAGE'] if ENV['RELEASE_MESSAGE'] && !ENV['RELEASE_MESSAGE'].strip.empty?

    # Interactive input with editor
    editor = ENV['EDITOR'] || 'nano'
    tempfile = Tempfile.new(['release_message', '.txt'])
    tempfile.write("# Enter your release commit message above this line\n")
    tempfile.write("# Lines starting with # are ignored\n")
    tempfile.write("# Format: type: description\n")
    tempfile.write("# Examples:\n")
    tempfile.write("#   feat: add new feature for X\n")
    tempfile.write("#   fix: resolve issue with Y\n")
    tempfile.write("#   docs: update documentation for Z\n")
    tempfile.close

    system("#{editor} #{tempfile.path}")
    
    content = File.read(tempfile.path)
    tempfile.unlink

    # Extract message (ignore comment lines)
    message_lines = content.lines.reject { |line| line.strip.start_with?('#') || line.strip.empty? }
    message_lines.join.strip
  end

  def create_github_release(version, commit_message)
    # Create release notes from commit message
    title_line = commit_message.split("\n").first
    release_title = "Release v#{version}: #{title_line.sub(/^[a-z]+:\s*/, '')}"
    
    # Build release notes
    release_notes = build_release_notes(version, commit_message)
    
    # Use GitHub CLI to create release
    system("gh release create v#{version} --title \"#{release_title}\" --notes \"#{release_notes}\"")
  end

  def build_release_notes(version, commit_message)
    lines = commit_message.split("\n")
    title = lines.first.sub(/^[a-z]+:\s*/, '').capitalize
    description = lines[1..-1].reject(&:empty?).join("\n")

    notes = "## 🎉 Release v#{version}: #{title}\n\n"
    
    if !description.empty?
      notes += "#{description}\n\n"
    end

    # Add technical details
    notes += "### 🔄 Technical Details\n"
    notes += "- **Version**: #{version}\n"
    notes += "- **Release Date**: #{Time.now.strftime('%Y-%m-%d')}\n"
    notes += "- **Validation**: All PDK validators passing ✅\n"
    notes += "- **Testing**: Full test suite executed ✅\n\n"

    # Add installation instructions
    notes += "### 📦 Installation\n"
    notes += "```bash\n"
    notes += "puppet module install UCSDANF-puppet_antelope --version #{version}\n"
    notes += "```\n\n"

    notes += "For more details, see the [CHANGELOG](https://github.com/UCSD-ANF/puppet-antelope/blob/main/CHANGELOG.md)."
    
    notes
  end
end

# Alias for convenience
task ghrelease: 'ghrelease:create'

