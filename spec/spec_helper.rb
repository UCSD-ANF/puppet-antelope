require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

module Helpers
  class Data
    def self.shared_facts
      {
        :concat_basedir => '/foo/bar/baz',
        :fqdn           => 'testhost.testfqdn',
        :hostname       => 'testhost',
      }
    end
    def self.supported_platforms
      [ 'centos6','centos7' ]
    end
    def self.unsupported_platforms
      [ 'sol10s','ubuntu14' ]
    end
    def self.all_platforms
      return [ self.supported_platforms,self.unsupported_platforms
      ].flatten.sort_by(&String.natural_order)
    end
  end
end

RSpec.configure do |c|
  # Override puppetlabs_spec_helper's setting of mock_with to :mocha,
  # per https://github.com/jenkinsci/puppet-jenkins/blob/2b475e4aac927f9abd336388a37872349b894f93/spec/spec_helper.rb
  c.mock_with :rspec
end

## Shared contexts to cut down on copy/paste testing code
# shared variables for all contexts are defined in the Helpers class above
shared_context 'Unsupported Platform' do
  it 'should complain about being unsupported' do
    should raise_error(Puppet::Error,/unsupported/i)
  end
end

shared_context 'centos6' do
  before do
    @shared_platform_facts = {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :architecture              => 'x86_64',
      :hardwareisa               => 'x86_64',
      :kernel                    => 'Linux',
      :kernelmajversion          => '2.6',
      :kernelrelease             => '2.6.32-504.16.2.el6.x86_64',
      :kernelversion             => '2.6.32',
      :lsbmajdistrelease         => '6',
      :operatingsystemmajrelease => '6',
      :operatingsystemrelease    => '6.6',
      :memorysize_mb             => '8192',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'centos7' do
  before do
    @shared_platform_facts = {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :architecture              => 'x86_64',
      :hardwareisa               => 'x86_64',
      :kernel                    => 'Linux',
      :kernelmajversion          => '3.10',
      :kernelrelease             => '3.10.0-229.1.2.el7.x86_644',
      :kernelversion             => '3.10.0',
      :lsbmajdistrelease         => '7',
      :operatingsystemmajrelease => '7',
      :operatingsystemrelease    => '7.1.1503',
      :memorysize_mb             => '8192',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'darwin13' do
  before do
    @shared_platform_facts = {
      :osfamily                    => 'Darwin',
      :operatingsystem             => 'Darwin',
      :operatingsystemmajrelease   => '13',
      :operatingsystemrelease      => '13.4.0',
      :kernel                      => 'Darwin',
      :kernelmajversion            => '13.4',
      :kernelrelease               => '13.4.0',
      :kernelversion               => '13.4.0',
      :macosx_productname          => 'Mac OS X',
      :macosx_productversion       => '10.9.5',
      :macosx_productversion_major => '10.9',
      :macosx_productversion_minor => '5',
      :memorysize_mb               => '8192',
      :xcodebuild_version          => '6.1',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'darwin14' do
  before do
    @shared_platform_facts = {
      :osfamily                    => 'Darwin',
      :operatingsystem             => 'Darwin',
      :operatingsystemrelease      => '14.0.0',
      :operatingsystemmajrelease   => '14',
      :kernel                      => 'Darwin',
      :kernelmajversion            => '14.0',
      :kernelrelease               => '14.0.0',
      :kernelversion               => '14.0.0',
      :macosx_productname          => 'Mac OS X',
      :macosx_productversion       => '10.10.1',
      :macosx_productversion_major => '10.10',
      :macosx_productversion_minor => '1',
      :memorysize_mb               => '8192',
      :xcodebuild_version          => '6.1.1',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'darwin15' do
  before do
    @shared_platform_facts = {
      :osfamily                    => 'Darwin',
      :operatingsystem             => 'Darwin',
      :operatingsystemrelease      => '15.0.0',
      :operatingsystemmajrelease      => '15',
      :kernel                      => 'Darwin',
      :kernelmajversion            => '15.0',
      :kernelrelease               => '15.0.0',
      :kernelversion               => '15.0.0',
      :macosx_productname          => 'Mac OS X',
      :macosx_productversion       => '10.11.1',
      :macosx_productversion_major => '10.11',
      :macosx_productversion_minor => '1',
      :memorysize_mb               => '8192',
      :xcodebuild_version          => '7.1',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'sol10s' do
  before do
    @shared_platform_facts = {
      :osfamily                  => 'Solaris',
      :operatingsystem           => 'Solaris',
      :hardwareisa               => 'sparc',
      :kernel                    => 'SunOS',
      :kernelrelease             => '5.10',
      :kernelmajversion          => 'Generic_144488-11',
      :kernelversion             => 'Generic_144488-11',
      :operatingsystemmajrelease => '10',
      :operatingsystemrelease    => '10_u8',
      :memorysize_mb             => '8000',
      :zonename                  => 'global',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'ubuntu14' do
  before do
    @shared_platform_facts = {
      :memorysize_mb             => '8000',
      :architecture              => 'amd64',
      :hardwareisa               => 'x86_64',
      :hardwaremodel             => 'x86_64',
      :kernel                    => 'Linux',
      :kernelmajversion          => '3.13',
      :kernelrelease             => '3.13.0-43-lowlatency',
      :kernelversion             => '3.13.0',
      :lsbdistcodename           => 'trusty',
      :lsbdistdescription        => 'Ubuntu 14.04.1 LTS',
      :lsbdistid                 => 'Ubuntu',
      :lsbdistrelease            => '14.04',
      :lsbmajdistrelease         => '14.04',
      :operatingsystem           => 'Ubuntu',
      :operatingsystemmajrelease => '14.04',
      :operatingsystemrelease    => '14.04',
      :osfamily                  => 'Debian',
      :type                      => 'Desktop',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

