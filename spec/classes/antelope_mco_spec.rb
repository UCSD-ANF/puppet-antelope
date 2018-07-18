# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::mco' do
  shared_context 'Supported Platform' do
    context 'with ensure==absent' do
      let(:params) { { ensure: 'absent' } }

      it {
        should contain_file('/usr/libexec/mcollective/agent/antelope.ddl')\
          .with_ensure('absent')
      }
      it {
        should contain_file('/usr/libexec/mcollective/agent/antelope.rb')\
          .with_ensure('absent')
      }
    end

    context 'with ensure==present' do
      baseparams = { ensure: 'present' }

      let(:params) { baseparams }

      it {
        should contain_file('/usr/libexec/mcollective/agent/antelope.ddl')\
          .with_ensure('present')
      }
      it {
        should contain_file('/usr/libexec/mcollective/agent/antelope.rb')\
          .with_ensure('present')
      }

      context 'on a client_only system' do
        let(:params) do
          { client_only: true }.merge(baseparams)
        end
        it {
          should contain_file('/usr/libexec/mcollective/agent/antelope.ddl')\
            .with_ensure('present')
        }
        it {
          should contain_file('/usr/libexec/mcollective/agent/antelope.rb')\
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
            mode: '0666'
          }
        end

        it do
          should contain_file('/test/basedir/agent/antelope.ddl').with(
            mode: '0666',
            owner: 'testowner',
            group: 'testgroup'
          )
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
