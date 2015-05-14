require 'spec_helper'

describe 'antelope::sync' do
  context 'on a supported osfamily' do
    let(:facts) { { :osfamily => 'RedHat' } }

    context 'with ensure==absent' do
      let(:params) { { :ensure => 'absent' } }

      it { should contain_file('antelope_sync').with_ensure('absent') }
      it { should contain_file('rsync_include').with_ensure('absent') }
      it { should contain_file('rsync_exclude').with_ensure('absent') }
    end

    context 'with ensure==present' do
      baseparams = {:ensure => 'present'}

      let(:params) { baseparams }
      context 'without a host defined' do
        it { should raise_error(Puppet::Error, /You must specify a value/) }
      end # without a host defined

      context 'with an anonymous rsync host defined' do
        let(:params) do
          { :host => 'rsync://my.sync.host' }.merge(baseparams)
        end

        it { should contain_file('antelope_sync')\
             .with_path('/usr/local/bin/antelope_sync')\
             .with_mode('0555')\
             .with_owner('root')\
             .with_group('root')\
             .with_content(/my @rsyncOpts=\("-a", '--partial', "--delete"\);/)
        }
        it { should contain_file('rsync_exclude')\
             .with_path('/usr/local/etc/rsync_exclude')
        }
        it { should contain_file('rsync_include')\
             .with_path('/usr/local/etc/rsync_include')
        }
      end # with an anonymous rsync host defined

      context 'with an SSH host defined' do
        let(:params) do
          { :host => 'my.sync.host' }.merge(baseparams)
        end

        it { should contain_file('antelope_sync')\
             .with_path('/usr/local/bin/antelope_sync')\
             .with_mode('0555')\
             .with_owner('root')\
             .with_group('root')\
             .with_content(/my @rsyncOpts=\("-a", '--partial', "--delete", "--rsh=ssh"\);/)
        }
      end # with an SSH host defined
    end # with ensure == present
  end # on a supported osfamily
end
