source 'https://rubygems.org'

### Environment variable version overrrides

# facter
facter_version = ENV.key?('FACTER_VERSION') ? "= #{ENV['FACTER_VERSION']}" : \
  '= 1.7.5' # from puppet enterprise 3.2.3
# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 3.4.3' # from puppet enterprise 3.2.3
# hiera
hiera_version = ENV.key?('HIERA_VERSION') ? "= #{ENV['HIERA_VERSION']}" : \
  '= 1.3.2' # from puppet enterprise 3.2.3
# hiera-puppet
#hiera_puppet_version = ENV.key?('HIERA_PUPPET_VERSION') ? \
#  "= #{ENV['HIERA_PUPPET_VERSION']}" : '= 1.0.0' # from puppet enterprise 3.2.3
# rspec (keep it in the 2.9 series due to our old version of rspec-puppet)
rspec_version = ENV.key?('RSPEC_VERSION') ? "= #{ENV['RSPEC_VERSION']}" : \
  '~> 2.9'


### Gem requirements
gem 'rake'
gem 'rspec', rspec_version
gem 'facter', facter_version
gem 'puppet', puppet_version
gem 'rspec-puppet'
#gem 'rcov'

gem 'puppet-lint'

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem "ci_reporter_rspec"
