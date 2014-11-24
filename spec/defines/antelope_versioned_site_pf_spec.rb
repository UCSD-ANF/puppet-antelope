require 'spec_helper'

describe 'antelope::versioned_site_pf' do
  let(:title) { '5.3pre' }
  context 'on a supported platform' do
    let(:facts) { {
      :osfamily => 'RedHat',
    } }

    it { should contain_file('antelope site.pf 5.3pre').with( {
      :path   => '/opt/antelope/5.3pre/data/pf/site.pf',
      :ensure => 'present',
    } ) }

    context 'with ensure == garbage' do
      let(:params) { {
        :ensure => 'garbage',
      } }

      it do
        expect { should compile }.to raise_error(Puppet::Error,
                                                 /does not match/)
      end
    end

    context 'with ensure == present' do
      let(:params) { {
        :ensure => 'present',
      } }

      it { should contain_file('antelope site.pf 5.3pre').with( {
        :ensure => 'present',
      } ) }
    end

    context 'with ensure == absent' do
      let(:params) { {
        :ensure => 'absent',
      } }

      it { should contain_file('antelope site.pf 5.3pre').with( {
        :ensure => 'absent',
      } ) }
    end

    context 'with params owner and group = pkgbuild' do
      let(:params) { {
        :owner => 'pkgbuild',
        :group => 'pkgbuild',
      } }

      it { should contain_file('antelope site.pf 5.3pre').with( {
        :owner  => 'pkgbuild',
        :group  => 'pkgbuild',
        :ensure => 'present',
      } ) }
    end

    context 'with global variables' do
      let(:pre_condition) { [
        "$antelope_dist_owner = 'guser'",
        "$antelope_dist_group = 'ggroup'",
      ] }

      it { should contain_file('antelope site.pf 5.3pre')\
        .with_owner('guser').with_group('ggroup') }
    end

    context 'with both source and content parameters' do
      let(:params) { {
        :source => '/this/should/fail',
        :content => 'This garbage content should fail',
      } }

      it {
        expect { should raise_error(Puppet::Error) }
      }
    end

    context 'with basic params' do
      let(:params) { {
        :mailhost                 => 'smtp.example.com',
        :mail_domain              => 'domain.example.com',
        :default_seed_network     => 'EX',
        :originating_organization => 'Example.com Inc.',
        :institution              => 'EXPL',
      } }

      it { should contain_file('antelope site.pf 5.3pre')\
        .with_content(/mailhost smtp\.example\.com/)\
        .with_content(/mail_domain domain\.example\.com/)\
        .with_content(/default_seed_network   EX/)\
        .with_content(/originating_organization Example\.com Inc\./)\
        .with_content(/Institution EXPL/)
      }

    end

    context 'with a title different from the version' do
      let(:title) { 'test antelope.pf' }
      let(:params) { {
        :version => '5.2-64',
      } }
      it { should contain_file('antelope site.pf test antelope.pf')\
        .with_path('/opt/antelope/5.2-64/data/pf/site.pf') }
    end

    context 'with a path defined' do
      let(:params) { {
        :path => '/path/to/test.pf',
      } }

      it { should contain_file('antelope site.pf 5.3pre')\
        .with_path('/path/to/test.pf') }
    end
  end

end
