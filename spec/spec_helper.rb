require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  # Override puppetlabs_spec_helper's setting of mock_with to :mocha,
  # per https://github.com/jenkinsci/puppet-jenkins/blob/2b475e4aac927f9abd336388a37872349b894f93/spec/spec_helper.rb
  c.mock_with :rspec
end
