require 'spec_helper'

describe 'antelope::versioned_license_pf' do
  let(:title) { '5.3' }
  context 'on a supported platform' do
    let(:facts) { {
      :osfamily => 'RedHat',
    } }

    it { should contain_file('antelope license.pf 5.3').with_path(
      '/opt/antelope/5.3/data/pf/license.pf') }

    context 'with params owner and group = pkgbuild' do
      let(:params) { {
        :owner => 'pkgbuild',
        :group => 'pkgbuild',
      } }

      it { should contain_file('antelope license.pf 5.3')\
        .with_owner('pkgbuild').with_group('pkgbuild') }
    end

    context 'with global variables' do
      let(:pre_condition) { [
        "$antelope_dist_owner = 'guser'",
        "$antelope_dist_group = 'ggroup'",
      ] }

      it { should contain_file('antelope license.pf 5.3')\
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

    context 'with a source parameter specified' do
      let(:params) {{
        :source => '/test/license.pf',
      }}

      it { should contain_file('antelope license.pf 5.3')\
        .with_source('/test/license.pf') }
    end

    context 'with a title different from the version' do
      let(:title) { 'test antelope.pf' }
      let(:params) { {
        :version => '5.2-64',
      } }
      it { should contain_file('antelope license.pf test antelope.pf')\
        .with_path('/opt/antelope/5.2-64/data/pf/license.pf') }
    end

    context 'with a path defined' do
      let(:params) { {
        :path => '/path/to/test.pf',
      } }

      it { should contain_file('antelope license.pf 5.3')\
        .with_path('/path/to/test.pf') }
    end
  end
end
