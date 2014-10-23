source 'https://rubygems.org'

### Environment variable version overrrides

# facter
facter_version = ENV.key?('FACTER_VERSION') ? "= #{ENV['FACTER_VERSION']}" : \
  '= 1.7.5' # from puppet enterprise 3.2.3
# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 3.4.3' # from puppet enterprise 3.2.3


### Gem requirements
gem 'rake'
gem 'rspec'
gem 'facter', facter_version
gem 'puppet', puppet_version
gem 'rspec-puppet', '>= 1.0.0'
#gem 'rcov'

gem 'puppet-lint'

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem 'ci_reporter_rspec'
