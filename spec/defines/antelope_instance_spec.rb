# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::instance', type: :define do
  let(:params) { { dirs: '/foo,/bar,/baz' } }
  let(:title) { 'myantelope' }

  shared_context 'dirs param provided' do
    let(:pre_condition) do
      [
        'user { "rt": }',
        'file { "/etc/facter/facts.d": ensure => "directory" }',
      ]
    end
  end

  shared_context 'dirs provided and ensure absent' do
    include_context 'dirs param provided'
    let(:params) do
      {
        ensure: 'absent',
        dirs: '/foo,/bar,/baz',
      }
    end
  end

  shared_context 'RedHat EL7' do
    it_behaves_like 'RedHat'
    context 'with dirs param provided' do
      include_context 'dirs param provided'
      it { is_expected.to contain_service('myantelope').with_provider('redhat') }
    end
  end

  shared_context 'RedHat not EL7' do
    it_behaves_like 'RedHat'
    context 'with dirs param provided' do
      include_context 'dirs param provided'
      it { is_expected.to contain_service('myantelope').with_provider(nil) }
    end
  end

  shared_context 'RedHat' do
    it_behaves_like 'Supported Platform'

    context 'with dirs param provided' do
      include_context 'dirs param provided'

      it {
        is_expected.to contain_exec(
          'chkconfig myantelope reset',
        ).with_path('/sbin')
      }

      context 'and ensure == absent' do
        include_context 'dirs provided and ensure absent'

        it { is_expected.not_to contain_exec('chkconfig myantelope reset') }
      end
    end
  end

  shared_context 'Supported Platform' do
    context 'without required params' do
      # raise_error test is broken for some unknown reason in Puppet 4 env.
      # Using a generic should_not compile in the mean time.
      # it { should raise_error(Puppet::ParseError,
      #  /^service enabled but no dirs specified/) }
      it { is_expected.not_to compile }
    end

    context 'with dirs provided' do
      include_context 'dirs param provided'

      it { is_expected.to compile }
      it {
        is_expected.to contain_file('/etc/init.d/myantelope').that_notifies(
          'Service[myantelope]',
        ).with_content(
          %r{@dirs = \( "\/foo", "\/bar", "\/baz" \);},
        )
      }
      it { is_expected.to contain_service('myantelope').that_requires('User[rt]') }

      it {
        is_expected.to contain_concat__fragment(
          '/etc/facter/facts.d/antelope_services_myantelope',
        )
      }
      it { is_expected.to contain_antelope__rtsystemdir('/foo') }
      it { is_expected.to contain_antelope__rtsystemdir('/bar') }
      it { is_expected.to contain_antelope__rtsystemdir('/baz') }

      context 'without managed fact' do
        let(:params) do
          super().merge(manage_fact: false)
        end

        it {
          is_expected.not_to contain_concat__fragment(
            '/etc/facter/facts.d/antelope_services_myantelope',
          )
        }
      end
      context 'with managed fact' do
        let(:params) do
          super().merge(manage_fact: true)
        end

        it {
          is_expected.to contain_concat__fragment(
            '/etc/facter/facts.d/antelope_services_myantelope',
          )
        }
      end

      context 'with manage_rtsystemdirs = true' do
        let(:params) do
          super().merge(manage_rtsystemdirs: true)
        end

        it { is_expected.to contain_antelope__rtsystemdir('/foo') }
        it { is_expected.to contain_antelope__rtsystemdir('/bar') }
        it { is_expected.to contain_antelope__rtsystemdir('/baz') }

        context 'with user = someguy and group = somegroup' do
          let(:pre_condition) do
            super() + ['user { "someguy": }']
          end

          let(:params) do
            super().merge(manage_rtsystemdirs: true,
                          user: 'someguy',
                          group: 'somegroup')
          end

          it {
            is_expected.to contain_antelope__rtsystemdir('/foo').with(
              owner: 'someguy',
              group: 'somegroup',
            )
          }
        end
      end

      context 'with manage_rtsystemdirs = false' do
        let(:params) do
          super().merge(manage_rtsystemdirs: false)
        end

        it { is_expected.not_to contain_antelope__rtsystemdir('/foo') }
        it { is_expected.not_to contain_antelope__rtsystemdir('/bar') }
        it { is_expected.not_to contain_antelope__rtsystemdir('/baz') }
      end

      context 'and with subscriptions to services' do
        let(:pre_condition) do
          super() + [
            'service { "foo": }',
            'exec    { "bar": }',
          ]
        end
        let(:params) do
          {
            dirs: '/foo,/bar,/baz',
            subscriptions: ['Service[foo]', 'Exec[bar]'],
          }
        end

        it {
          is_expected.to contain_exec('/etc/init.d/myantelope stop').with_refreshonly(true).with_notify(
            ['Service[foo]', 'Exec[bar]'],
          ).with_command(
            '/etc/init.d/myantelope stop "Puppet antelope: pause myantelope (per refresh of Service[foo], Exec[bar] ), using /etc/init.d/myantelope."',
          )
        }
        it {
          is_expected.to contain_exec('/etc/init.d/myantelope start').with_refreshonly(true).with_subscribe(
            ['Service[foo]', 'Exec[bar]'],
          )
        }
      end
      context 'and ensure == absent' do
        include_context 'dirs provided and ensure absent'

        it {
          is_expected.to contain_file('/etc/init.d/myantelope').that_requires(
            'Service[myantelope]',
          ).with_ensure('absent')
        }
        it { is_expected.to contain_service('myantelope').with_enable(false) }
        it {
          is_expected.to contain_concat__fragment(
            '/etc/facter/facts.d/antelope_services_myantelope',
          )
        }
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      if facts[:osfamily] == 'RedHat'
        if facts[:operatingsystemmajrelease].to_i >= 7
          it_behaves_like 'RedHat EL7'
        else
          it_behaves_like 'RedHat not EL7'
        end
      else
        it_behaves_like 'Supported Platform'
      end
    end
  end
end
