# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::rtsystemdir', type: :define do
  let(:title) { '/export/home/rt/rtsystems/test' }
  let(:pre_condition) do
    [
      'user { "rt": }',
      'group { "rt": }',
    ]
  end

  shared_context 'Supported Platform' do
    context 'with default parameters' do
      it { is_expected.to compile }
      
      it {
        is_expected.to contain_file('/export/home/rt/rtsystems/test/rtexec.pf').with(
          ensure: 'present',
          owner: 'rt',
          group: 'antelope',
          mode: '0664',
          replace: false,
        )
      }
    end

    context 'with custom parameters' do
      let(:params) do
        {
          owner: 'customuser',
          group: 'customgroup',
          dir_mode: '0755',
          rtexec_mode: '0600',
        }
      end
      let(:pre_condition) do
        [
          'user { "customuser": }',
          'group { "customgroup": }',
        ]
      end

      it { is_expected.to compile }
      
      it {
        is_expected.to contain_file('/export/home/rt/rtsystems/test/rtexec.pf').with(
          ensure: 'present',
          owner: 'customuser',
          group: 'customgroup',
          mode: '0600',
          replace: false,
        )
      }
    end

    context 'with custom path' do
      let(:params) do
        {
          path: '/custom/path/rtsystem',
        }
      end

      it { is_expected.to compile }
      
      it {
        is_expected.to contain_file('/custom/path/rtsystem/rtexec.pf').with(
          ensure: 'present',
          owner: 'rt',
          group: 'antelope',
          mode: '0664',
          replace: false,
        )
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