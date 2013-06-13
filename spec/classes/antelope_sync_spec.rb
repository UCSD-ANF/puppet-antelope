require 'spec_helper'

describe 'antelope::sync' do
  context 'on a supported osfamily' do
    let (:facts) { {
      :osfamily => 'RedHat',
    } }

    context 'without a sync_host defined' do
      it do
        expect {
          should contain_file('antelope_sync')
        }.to raise_error(Puppet::Error, /You must specify a value/)
      end
    end

    context 'with a sync_host defined' do
      let (:params) { {
        :sync_host => 'my.sync.host',
      } }

      it do
        should contain_file('antelope_sync')\
          .with_path('/usr/local/bin/antelope_sync')\
          .with_mode('0555')\
          .with_owner('root')\
          .with_group('root')

        should contain_file('rsync_exclude')\
          .with_path('/usr/local/etc/rsync_exclude')

        should contain_file('rsync_include')\
          .with_path('/usr/local/etc/rsync_include')
      end
    end

  end
end
