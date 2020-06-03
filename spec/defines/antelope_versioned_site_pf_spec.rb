# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::versioned_site_pf' do
  let(:title) { '5.3pre' }

  shared_context 'Supported Platform' do
    it {
      is_expected.to contain_file('antelope site.pf 5.3pre').with(
        path: '/opt/antelope/5.3pre/data/pf/site.pf',
        ensure: 'present',
      )
    }

    context 'with ensure == present' do
      let(:params) do
        {
          ensure: 'present',
        }
      end

      it {
        is_expected.to contain_file('antelope site.pf 5.3pre').with(
          ensure: 'present',
        )
      }
    end

    context 'with ensure == absent' do
      let(:params) do
        {
          ensure: 'absent',
        }
      end

      it {
        is_expected.to contain_file('antelope site.pf 5.3pre').with(
          ensure: 'absent',
        )
      }
    end

    context 'with params owner and group = pkgbuild' do
      let(:params) do
        {
          owner: 'pkgbuild',
          group: 'pkgbuild',
        }
      end

      it {
        is_expected.to contain_file('antelope site.pf 5.3pre').with(
          owner: 'pkgbuild',
          group: 'pkgbuild',
          ensure: 'present',
        )
      }
    end

    context 'with both source and content parameters' do
      let(:params) do
        {
          source: '/this/should/fail',
          content: 'This garbage content should fail',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{Can't specify both}) }
    end

    context 'with basic params' do
      let(:params) do
        {
          mailhost: 'smtp.example.com',
          mail_domain: 'domain.example.com',
          default_seed_network: 'EX',
          originating_organization: 'Example.com Inc.',
          institution: 'EXPL',
        }
      end

      it {
        is_expected.to contain_file('antelope site.pf 5.3pre')\
          .with_content(%r{mailhost smtp\.example\.com})\
          .with_content(%r{mail_domain domain\.example\.com})\
          .with_content(%r{default_seed_network   EX})\
          .with_content(%r{originating_organization Example\.com Inc\.})\
          .with_content(%r{Institution EXPL})
      }
    end

    context 'with a title different from the version' do
      let(:title) { 'test antelope.pf' }
      let(:params) do
        {
          version: '5.2-64',
        }
      end

      it {
        is_expected.to contain_file('antelope site.pf test antelope.pf')\
          .with_path('/opt/antelope/5.2-64/data/pf/site.pf')
      }
    end

    context 'with a path defined' do
      let(:params) do
        {
          path: '/path/to/test.pf',
        }
      end

      it {
        is_expected.to contain_file('antelope site.pf 5.3pre')\
          .with_path('/path/to/test.pf')
      }
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it_behaves_like 'Supported Platform'
    end
  end
end
