source 'https://rubygems.org'

### Environment variable version overrrides

# facter
facter_version = ENV.key?('FACTER_VERSION') ? "= #{ENV['FACTER_VERSION']}" : \
  '= 2.4.4' # from puppet enterprise 3.2.3
# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 3.8.5' # from puppet enterprise 3.2.3


### Gem requirements
gem 'rake', '<11'
gem 'json_pure', '<2.0'
gem 'rspec', '< 3.0.0'
gem 'facter', facter_version
gem 'puppet', puppet_version
gem 'rspec-puppet', '>= 2.0'
gem 'puppet-syntax', :require => false

#gem 'rcov'
gem 'parallel_tests', '<2.10.0', :require => false
# http://www.camptocamp.com/en/actualite/getting-code-ready-puppet-4/
gem 'puppet-lint-unquoted_string-check'
gem 'puppet-lint-empty_string-check'
gem 'puppet-lint-leading_zero-check'
gem 'puppet-lint-variable_contains_upcase'
gem 'puppet-lint-spaceship_operator_without_tag-check'
gem 'puppet-lint-absolute_classname-check'
gem 'puppet-lint-undef_in_function-check'
gem 'puppet-lint-roles_and_profiles-check'


gem 'puppet-lint'

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem 'ci_reporter_rspec'
