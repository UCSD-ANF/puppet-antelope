# frozen_string_literal: true

source 'https://rubygems.org'

### Environment variable version overrrides

# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 5.3.5'

### Gem requirements
gem 'json_pure'
gem 'puppet', puppet_version
gem 'puppet-syntax', require: false
gem 'rake'
gem 'rspec'
gem 'rspec-puppet', '2.5.0'
gem 'rubocop'
gem 'rubocop-rspec'

# gem 'rcov'
gem 'parallel_tests', require: false
# http://www.camptocamp.com/en/actualite/getting-code-ready-puppet-4/
gem 'puppet-lint-absolute_classname-check'
gem 'puppet-lint-empty_string-check'
gem 'puppet-lint-leading_zero-check'
gem 'puppet-lint-roles_and_profiles-check'
gem 'puppet-lint-spaceship_operator_without_tag-check'
gem 'puppet-lint-undef_in_function-check'
gem 'puppet-lint-unquoted_string-check'
gem 'puppet-lint-variable_contains_upcase'

gem 'puppet-lint'

gem 'ci_reporter_rspec'
gem 'git', '>= 1.2.6'
gem 'puppetlabs_spec_helper', '>= 2.9.1'
