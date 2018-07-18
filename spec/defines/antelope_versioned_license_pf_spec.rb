# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::versioned_license_pf' do
  let(:title) { '5.3' }
  shared_context 'Supported Platform' do
    it {
      should contain_file('antelope license.pf 5.3').with(
        path: '/opt/antelope/5.3/data/pf/license.pf',
        ensure: 'present'
      )
    }

    context 'with ensure == present' do
      let(:params) do
        {
          ensure: 'present'
        }
      end
      it {
        should contain_file('antelope license.pf 5.3').with(
          path: '/opt/antelope/5.3/data/pf/license.pf',
          ensure: 'present'
        )
      }
    end

    context 'with ensure == absent' do
      let(:params) do
        {
          ensure: 'absent'
        }
      end
      it {
        should contain_file('antelope license.pf 5.3').with(
          path: '/opt/antelope/5.3/data/pf/license.pf',
          ensure: 'absent'
        )
      }
    end

    context 'with ensure == garbage' do
      let(:params) do
        {
          ensure: 'garbage'
        }
      end

      it { should raise_error(Puppet::Error, /does not match/) }
    end

    context 'with params owner and group = pkgbuild' do
      let(:params) do
        {
          owner: 'pkgbuild',
          group: 'pkgbuild'
        }
      end

      it {
        should contain_file('antelope license.pf 5.3')\
          .with_owner('pkgbuild').with_group('pkgbuild')
      }
    end

    context 'with both source and content parameters' do
      let(:params) do
        {
          source: '/this/should/fail',
          content: 'This garbage content should fail'
        }
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'using template parameters' do
      context 'with a single license key' do
        let(:params) do
          {
            'license_keys' => 'tabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo.ucsd.edu Antelope 5.1'
          }
        end
        it {
          should contain_file('antelope license.pf 5.3')\
            .with_content(/^tabcdef/)
        }
      end

      context 'with multiple license keys' do
        let(:params) do
          {
            'license_keys' => [
              'tabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo.ucsd.edu Antelope 5.1',
              'nabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo.ucsd.edu Antelope 5.1'
            ]
          }
        end
        it {
          should contain_file('antelope license.pf 5.3')\
            .with_content(/^tabcdef.*\nnabcdef/)
        }
      end

      context 'with expiration_warnings unset' do
        it {
          should_not contain_file('antelope license.pf 5.3')\
            .with_content(/no_more_expiration_warnings/)
        }
      end

      context 'with expiration_warnings set to true' do
        let(:params) do
          {
            'expiration_warnings' => true
          }
        end
        it {
          should_not contain_file('antelope license.pf 5.3')\
            .with_content(/no_more_expiration_warnings/)
        }
      end

      context 'with expiration_warnings set to false' do
        let(:params) do
          {
            'expiration_warnings' => false
          }
        end
        it {
          should contain_file('antelope license.pf 5.3')\
            .with_content(/no_more_expiration_warnings/)
        }
      end
    end

    context 'with a source parameter specified' do
      let(:params) do
        {
          source: '/test/license.pf'
        }
      end

      it {
        should contain_file('antelope license.pf 5.3')\
          .with_source('/test/license.pf')
      }
    end

    context 'with a title different from the version' do
      let(:title) { 'test antelope.pf' }
      let(:params) do
        {
          version: '5.2-64'
        }
      end
      it {
        should contain_file('antelope license.pf test antelope.pf')\
          .with_path('/opt/antelope/5.2-64/data/pf/license.pf')
      }
    end

    context 'with a path defined' do
      let(:params) do
        {
          path: '/path/to/test.pf'
        }
      end

      it {
        should contain_file('antelope license.pf 5.3')\
          .with_path('/path/to/test.pf')
      }
    end
  end

  Helpers::Data.unsupported_platforms.each do |platform|
    context "on #{platform}" do
      include_context platform

      it_behaves_like 'Unsupported Platform'
    end
  end

  Helpers::Data.supported_platforms.each do |platform|
    context "on #{platform}" do
      include_context platform
      it_behaves_like 'Supported Platform'
    end
  end
end
