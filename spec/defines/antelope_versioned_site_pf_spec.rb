# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::versioned_site_pf' do
  let(:title) { '5.3pre' }
  shared_context 'Supported Platform' do
    it {
      should contain_file('antelope site.pf 5.3pre').with(
        path: '/opt/antelope/5.3pre/data/pf/site.pf',
        ensure: 'present'
      )
    }

    context 'with ensure == garbage' do
      let(:params) do
        {
          ensure: 'garbage'
        }
      end

      it { should raise_error(Puppet::Error, /does not match/) }
    end

    context 'with ensure == present' do
      let(:params) do
        {
          ensure: 'present'
        }
      end

      it {
        should contain_file('antelope site.pf 5.3pre').with(
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
        should contain_file('antelope site.pf 5.3pre').with(
          ensure: 'absent'
        )
      }
    end

    context 'with params owner and group = pkgbuild' do
      let(:params) do
        {
          owner: 'pkgbuild',
          group: 'pkgbuild'
        }
      end

      it {
        should contain_file('antelope site.pf 5.3pre').with(
          owner: 'pkgbuild',
          group: 'pkgbuild',
          ensure: 'present'
        )
      }
    end

    context 'with both source and content parameters' do
      let(:params) do
        {
          source: '/this/should/fail',
          content: 'This garbage content should fail'
        }
      end

      it {
        expect { should raise_error(Puppet::Error) }
      }
    end

    context 'with basic params' do
      let(:params) do
        {
          mailhost: 'smtp.example.com',
          mail_domain: 'domain.example.com',
          default_seed_network: 'EX',
          originating_organization: 'Example.com Inc.',
          institution: 'EXPL'
        }
      end

      it {
        should contain_file('antelope site.pf 5.3pre')\
          .with_content(/mailhost smtp\.example\.com/)\
          .with_content(/mail_domain domain\.example\.com/)\
          .with_content(/default_seed_network   EX/)\
          .with_content(/originating_organization Example\.com Inc\./)\
          .with_content(/Institution EXPL/)
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
        should contain_file('antelope site.pf test antelope.pf')\
          .with_path('/opt/antelope/5.2-64/data/pf/site.pf')
      }
    end

    context 'with a path defined' do
      let(:params) do
        {
          path: '/path/to/test.pf'
        }
      end

      it {
        should contain_file('antelope site.pf 5.3pre')\
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
