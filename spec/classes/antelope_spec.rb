# frozen_string_literal: true

require 'spec_helper'

describe 'antelope' do
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
          /@dirs = \( "\/export\/home\/rt\/rtsystems\/test" \);/,
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
          /@dirs = \( "\/export\/home\/rt\/rtsystems\/foo", "\/export\/home\/rt\/rtsystems\/bar" \);/,
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
