# frozen_string_literal: true

require 'spec_helper'

describe 'antelope' do
  basefacts = {
    antelope_contrib_basedir: {
      '5.7' => '/contrib',
      '5.8' => '/contrib',
      '5.9' => '/contrib',
      '5.10pre' => '/contrib',
    },
    antelope_latest_perl: 'perl5.26.1',
    antelope_latest_python: 'python3.6.5',
    antelope_latest_version: '5.10pre',
    antelope_services: 'antelope',
    antelope_versions: '5.7,5.8,5.9,5.10pre',
    antelope_versions_array: [
      '5.7',
      '5.8',
      '5.9',
      '5.10pre',
    ],
    antelope_versions_supports_aldproxy: '5.7,5.8,5.9,5.10pre',
    antelope_versions_supports_aldproxy_array: [
      '5.7',
      '5.8',
      '5.9',
      '5.10pre',
    ],
  }
  shared_context 'Supported Platform' do
    let(:pre_condition) do
      [
        "user { 'rt': }",
        "file { '/etc/facter/facts.d': }",
      ]
    end

    context 'with no dirs or instances' do
      it { is_expected.not_to contain_antelope__instance('antelope') }
    end

    context 'with a single dir' do
      let(:params) do
        {
          dirs: '/export/home/rt/rtsystems/test',
        }
      end

      it { is_expected.to contain_antelope__instance('antelope') }
      it {
        is_expected.to contain_file('/etc/init.d/antelope').with_content(
          %r{@dirs = \( "\/export\/home\/rt\/rtsystems\/test" \);},
        )
      }
    end

    context 'with a multiple dirs' do
      let(:params) do
        {
          dirs: [
            '/export/home/rt/rtsystems/foo',
            '/export/home/rt/rtsystems/bar',
          ],
        }
      end

      it { is_expected.to contain_antelope__instance('antelope') }
      it {
        is_expected.to contain_file('/etc/init.d/antelope').with_content(
          %r{@dirs = \( "\/export\/home\/rt\/rtsystems\/foo", "\/export\/home\/rt\/rtsystems\/bar" \);},
        )
      }
    end

    context 'with instances hash' do
      instance_params = {
        instances: {
          'antelope-single' => {
            'user' => 'rt',
            'dirs' => '/export/home/rt/rtsystems/single',
          },
          'antelope-csv' => {
            'user' => 'rt',
            'dirs' => '/export/home/rt/rtsystems/csv1,/export/home/rt/rtsystems/csv2',
          },
          'antelope-arr' => {
            'user' => 'rt',
            'dirs' => [
              '/export/home/rt/rtsystems/arr1',
              '/export/home/rt/rtsystems/arr2',
            ],
          },
        },
      }

      let(:params) { instance_params }

      it do
        is_expected.to contain_antelope__instance('antelope-single')
        is_expected.to contain_antelope__instance('antelope-csv')
        is_expected.to contain_antelope__instance('antelope-arr')
      end

      context 'with instance_subscribe array' do
        let(:pre_condition) do
          super() + ["service {'foo':}"]
        end

        let(:params) do
          p = { instance_subscribe: ['Service[foo]'] }
          super().merge(p)
        end

        it do
          is_expected.to contain_antelope__instance('antelope-single').with(
            'subscriptions' => ['Service[foo]'],
            :ensure => 'present',
          )
          is_expected.to contain_antelope__instance('antelope-csv')
          is_expected.to contain_antelope__instance('antelope-arr')
        end
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge(basefacts) }

      it_behaves_like 'Supported Platform'
    end
  end
end
