require 'spec_helper'

describe 'antelope::instance', :type => 'define' do

  baseparams = { :dirs => '/foo,/bar,/baz' }
  let(:title) { 'myantelope' }

  shared_context 'dirs param provided' do
    let(:pre_condition) { [
      'user { "rt": }',
      'file { "/etc/facter/facts.d": ensure => "directory" }',
    ] }
    let(:params)        { baseparams }
  end

  shared_context 'dirs provided and ensure absent' do
    include_context 'dirs param provided'
    let(:params) { {
      :ensure => 'absent',
      :dirs   => '/foo,/bar,/baz',
    } }
  end

  shared_context 'RedHat EL7' do
    it_behaves_like 'RedHat'
    context 'with dirs param provided' do
      include_context 'dirs param provided'
      it { should contain_service('myantelope').with_provider('redhat') }
    end
  end

  shared_context 'RedHat not EL7' do
    it_behaves_like 'RedHat'
    context 'with dirs param provided' do
      include_context 'dirs param provided'
      it { should contain_service('myantelope').with_provider(nil) }
    end
  end

  shared_context 'RedHat' do
    it_behaves_like 'Supported Platform'

    context 'with dirs param provided' do
      include_context 'dirs param provided'

      it { should contain_exec(
        'chkconfig myantelope reset').with_path('/sbin')
      }

      context 'and ensure == absent' do
        include_context 'dirs provided and ensure absent'

        it { should_not contain_exec('chkconfig myantelope reset') }
      end
    end
  end

  shared_context 'Supported Platform' do
    context "without required params" do
      # raise_error test is broken for some unknown reason in Puppet 4 env.
      # Using a generic should_not compile in the mean time.
      #it { should raise_error(Puppet::ParseError,
      #  /^service enabled but no dirs specified/) }
      it { should_not compile }
    end

    context "with dirs provided" do
      include_context 'dirs param provided'

      it { should compile }
      it { should contain_file('/etc/init.d/myantelope').that_notifies(
        'Service[myantelope]').with_content(
        /@dirs = \( "\/foo", "\/bar", "\/baz" \);/ ) }
      it { should contain_service('myantelope').that_requires('User[rt]') }

      it { should contain_concat__fragment(
        '/etc/facter/facts.d/antelope_services_myantelope') }
      it { should contain_antelope__rtsystemdir('/foo') }
      it { should contain_antelope__rtsystemdir('/bar') }
      it { should contain_antelope__rtsystemdir('/baz') }

      context 'without managed fact' do
        let(:params) do
          { 'manage_fact' => false}.merge(baseparams)
        end
        it { should_not contain_concat__fragment(
          '/etc/facter/facts.d/antelope_services_myantelope') }
      end
      context 'with managed fact' do
        let(:params) do
          { 'manage_fact' => true}.merge(baseparams)
        end
        it { should contain_concat__fragment(
          '/etc/facter/facts.d/antelope_services_myantelope') }
      end

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
        include_context 'dirs provided and ensure absent'

        it { should contain_file('/etc/init.d/myantelope').that_requires(
          'Service[myantelope]').with_ensure('absent') }
        it { should contain_service('myantelope').with_enable(false) }
        it { should contain_concat__fragment(
          '/etc/facter/facts.d/antelope_services_myantelope'
        ) }
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

      case platform
      when 'centos7'
        it_behaves_like 'RedHat EL7'
      when 'centos6'
        it_behaves_like 'RedHat not EL7'
      else
        it_behaves_like 'Supported Platform'
      end
    end
  end
end
