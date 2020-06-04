# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::mco' do
  shared_context 'Supported Platform' do
    context 'with ensure==absent' do
      let(:params) { { ensure: 'absent' } }

      it {
        is_expected.to contain_file('/usr/libexec/mcollective/agent/antelope.ddl')\
          .with_ensure('absent')
      }
      it {
        is_expected.to contain_file('/usr/libexec/mcollective/agent/antelope.rb')\
          .with_ensure('absent')
      }
    end

    context 'with ensure==present' do
      let(:params) { { ensure: 'present' } }

      it {
        is_expected.to contain_file('/usr/libexec/mcollective/agent/antelope.ddl')\
          .with_ensure('present')
      }
      it {
        is_expected.to contain_file('/usr/libexec/mcollective/agent/antelope.rb')\
          .with_ensure('present')
      }

      context 'on a client_only system' do
        let(:params) do
          super().merge(client_only: true)
        end

        it {
          is_expected.to contain_file('/usr/libexec/mcollective/agent/antelope.ddl')\
            .with_ensure('present')
        }
        it {
          is_expected.to contain_file('/usr/libexec/mcollective/agent/antelope.rb')\
            .with_ensure('absent')
        }
      end

      context 'with parameters defined' do
        let(:params) do
          {
            plugin_basedir: '/test/basedir',
            mco_etc: '/test/etc',
            owner: 'testowner',
            group: 'testgroup',
            mode: '0666',
          }
        end

        it do
          is_expected.to contain_file('/test/basedir/agent/antelope.ddl').with(
            mode: '0666',
            owner: 'testowner',
            group: 'testgroup',
          )
        end
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it_behaves_like 'Supported Platform'
    end
  end
end
