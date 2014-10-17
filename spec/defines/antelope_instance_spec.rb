require 'spec_helper'

describe 'antelope::instance', :type => 'define' do
  basefacts = { :concat_basedir => '/concat' }
  let(:title) { 'myantelope' }
  # Supported OS checks
  [
    { :osfamily => 'RedHat',  :operatingsystem => 'CentOS' },
    { :osfamily => 'Solaris', :operatingsystem => 'Solaris' },
  ].each { |os|

    context "on supported OS #{os[:operatingsystem]} without params" do
      let(:facts) do os.merge(basefacts) end
      it { expect { should compile }.to raise_error(Puppet::Error,
        /^service enabled but no dirs specified/)
      }
    end

    context "on supported OS #{os[:operatingsystem]} with dirs" do
      baseparams = { :dirs => '/foo,/bar,/baz' }
      let(:pre_condition) { 'user { "rt": }' }
      let(:facts)         { os.merge(basefacts) }
      let(:params)        { baseparams }

      it { expect { should compile } }
      it { should contain_file('/etc/init.d/myantelope').that_notifies(
        'Service[myantelope]').with_content(
        /@dirs = \( "\/foo", "\/bar", "\/baz" \);/ ) }
      it { should contain_service('myantelope').that_requires('User[rt]') }
      it { should contain_concat__fragment(
        '/etc/facter/facts.d/antelope_services_myantelope') }
      it { should contain_antelope__rtsystemdir('/foo') }
      it { should contain_antelope__rtsystemdir('/bar') }
      it { should contain_antelope__rtsystemdir('/baz') }

      context "with manage_rtsystemdirs = true" do
        let(:params) do
          { 'manage_rtsystemdirs' => true }.merge(baseparams)
        end

        it { should contain_antelope__rtsystemdir('/foo') }
        it { should contain_antelope__rtsystemdir('/bar') }
        it { should contain_antelope__rtsystemdir('/baz') }

        context "with user = someguy and group = somegroup" do
          let(:pre_condition) { 'user { "someguy": }' }
          let(:params) do
            { 'manage_rtsystemdirs' => true,
              :user                 => 'someguy',
              :group                => 'somegroup',
            }.merge(baseparams)
          end

          it { should contain_antelope__rtsystemdir('/foo').with({
            :owner => 'someguy',
            :group => 'somegroup',
          }) }
        end

      end

      context "with manage_rtsystemdirs = false" do
        let(:params) do
          { 'manage_rtsystemdirs' => false }.merge(baseparams)
        end

        it { should_not contain_antelope__rtsystemdir('/foo') }
        it { should_not contain_antelope__rtsystemdir('/bar') }
        it { should_not contain_antelope__rtsystemdir('/baz') }
      end


      case os[:osfamily]
      when 'RedHat' then

        it { should contain_exec(
          'chkconfig myantelope reset').with_path('/sbin') }

      when 'Solaris' then
        it { should contain_file('/etc/rc0.d/K01myantelope').with_ensure(
          'link').that_requires('File[/etc/init.d/myantelope]') }

        it { should contain_file('/etc/rc1.d/K01myantelope').with_ensure(
          'link').that_requires('File[/etc/init.d/myantelope]') }

        it { should contain_file('/etc/rc3.d/S99myantelope').with_ensure(
          'link').that_requires('File[/etc/init.d/myantelope]') }
      end

      context "and with subscriptions to services" do
        let(:pre_condition) do [
          'user    { "rt": }',
          'service { "foo": }',
          'exec    { "bar": }',
        ] end
        let(:params) do {
          :dirs          => '/foo,/bar,/baz',
          :subscriptions => ['Service["foo"]','Exec["bar"]'],
        } end
        it { should contain_exec('/etc/init.d/myantelope stop'
                                ).with_refreshonly(true).with_notify(
                                ['Service["foo"]','Exec["bar"]']
                                ).with_command(
                                /\/etc\/init\.d\/myantelope stop 'Puppet antelope: pause myantelope \(per refresh of Service\["foo"\], Exec\["bar"\]/
                                ) }
        it { should contain_exec('/etc/init.d/myantelope start'
                                ).with_refreshonly(true).with_subscribe(
                                ['Service["foo"]','Exec["bar"]']
                                ) }
      end
      context "and ensure == absent" do
        let(:params) do {
          :ensure => 'absent',
          :dirs   => '/foo,/bar,/baz',
        } end
        it { should contain_file('/etc/init.d/myantelope').that_requires(
          'Service[myantelope]').with_ensure('absent') }
        it { should contain_service('myantelope').with_enable(false) }
        it { should contain_concat__fragment(
          '/etc/facter/facts.d/antelope_services_myantelope'
        ).with_ensure('absent') }

        case os[:osfamily]
        when 'RedHat' then

          it { should_not contain_exec('chkconfig myantelope reset') }

        when 'Solaris' then
          it { should contain_file('/etc/rc0.d/K01myantelope').with_ensure(
            'absent').that_requires('File[/etc/init.d/myantelope]') }

          it { should contain_file('/etc/rc1.d/K01myantelope').with_ensure(
            'absent').that_requires('File[/etc/init.d/myantelope]') }

          it { should contain_file('/etc/rc3.d/S99myantelope').with_ensure(
            'absent').that_requires('File[/etc/init.d/myantelope]') }
        end
      end
    end
  }

  # Unsupported OS checks
  [
    { :osfamily => 'Darwin',  :operatingsystem => 'Darwin'  },
    { :osfamily => 'FreeBSD', :operatingsystem => 'FreeBSD' },
    { :osfamily => 'debian',  :operatingsystem => 'ubuntu'  },
  ].each { |os|
    context "on unsupported OS #{os[:operatingsystem]}" do
      let(:facts) do os.merge(basefacts) end
      case os[:operatingsystem]
      when 'Darwin' then
        # Darwin is supported by this module, but not by this type.
        it { expect { should compile }.to raise_error(Puppet::Error,
          /^Unsupported.*instance\.pp/)
        }
      else
        # antelope::params should fail out anything else.
        it { expect { should compile }.to raise_error(Puppet::Error,
          /^This module does not work on.*params\.pp/)
        }
      end
    end
  }
end
