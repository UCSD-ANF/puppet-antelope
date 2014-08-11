require 'spec_helper'

describe 'antelope::sync' do
  context 'on a supported osfamily' do
    let (:facts) do { :osfamily => 'RedHat' } end

    context 'without a sync_host defined' do
      it do
        expect {
          should contain_file('antelope_sync')
        }.to raise_error(Puppet::Error, /You must specify a value/)
      end
    end

    context 'with an anonymous rsync sync_host defined' do
      let (:params) do { :sync_host => 'rsync://my.sync.host' } end

      it { should contain_file('antelope_sync')\
          .with_path('/usr/local/bin/antelope_sync')\
          .with_mode('0555')\
          .with_owner('root')\
          .with_group('root')\
          .with_content(/my @rsyncOpts=\("-a", "--delete"\);/)
      }
      it { should contain_file('rsync_exclude')\
          .with_path('/usr/local/etc/rsync_exclude')
      }
      it { should contain_file('rsync_include')\
          .with_path('/usr/local/etc/rsync_include')
      }
    end
    context 'with an SSH sync_host defined' do
      let (:params) do { :sync_host => 'my.sync.host' } end

      it { should contain_file('antelope_sync')\
          .with_path('/usr/local/bin/antelope_sync')\
          .with_mode('0555')\
          .with_owner('root')\
          .with_group('root')\
          .with_content(/my @rsyncOpts=\("-a", "--delete", "--rsh=ssh -q"\);/)
      }
    end
  end
end
