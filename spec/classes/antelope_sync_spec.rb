# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::sync' do
  let(:pre_condition) do
    [
      'file{"/usr/local/bin":}',
      'file{"/usr/local/etc":}',
    ]
  end

  shared_context 'Supported Platform' do
    context 'with ensure==absent' do
      let(:params) { { ensure: 'absent' } }

      it { is_expected.to contain_file('antelope_sync').with_ensure('absent') }
      it { is_expected.to contain_file('rsync_include').with_ensure('absent') }
      it { is_expected.to contain_file('rsync_exclude').with_ensure('absent') }
    end

    context 'with ensure==present' do
      let(:params) { { ensure: 'present'} }

      context 'without a host defined' do
        it { is_expected.to raise_error(Puppet::Error, %r{You must specify a value}) }
      end # without a host defined

      context 'with an anonymous rsync host defined' do
        let(:params) do
          super().merge(host: 'rsync://my.sync.host')
        end

        it {
          is_expected.to contain_file('antelope_sync')\
            .with_path('/usr/local/bin/antelope_sync')\
            .with_mode('0555')\
            .with_owner('root')\
            .with_group('root')\
            .with_content(%r{my @rsyncOpts=\("-a", '--partial', "--delete"\);})
        }
        it {
          is_expected.to contain_file('rsync_exclude')\
            .with_path('/usr/local/etc/rsync_exclude')
        }
        it {
          is_expected.to contain_file('rsync_include')\
            .with_path('/usr/local/etc/rsync_include')
        }
      end # with an anonymous rsync host defined

      context 'with an SSH host defined' do
        let(:params) do
          super().merge( host: 'my.sync.host')
        end

        it {
          is_expected.to contain_file('antelope_sync')\
            .with_path('/usr/local/bin/antelope_sync')\
            .with_mode('0555')\
            .with_owner('root')\
            .with_group('root')\
            .with_content(%r{my @rsyncOpts=\("-a", '--partial', "--delete", "--rsh=ssh"\);})
        }
      end # with an SSH host defined
    end # with ensure == present
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it_behaves_like 'Supported Platform'
    end
  end
end
