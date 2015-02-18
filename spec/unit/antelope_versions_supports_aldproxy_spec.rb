require 'spec_helper'
require 'facter/antelope_versions_supports_aldproxy'
require 'facter/util/antelope'

['antelope_versions_supports_aldproxy',
 'antelope_versions_supports_aldproxy_array'
].each { |a|
  describe "#{a} fact", :type => :fact do
    let(:fact) { Facter.fact(a.to_sym) }
    subject(a.to_sym) { fact.value }

    before :each do
      Facter::Util::Antelope.should_receive(:get_versions).and_return([
        '5.2-64', '5.4', '5.4post'])
      File.should_receive('exist?').with(
        '/opt/antelope/5.2-64/bin/ald_proxy').and_return(false)
      File.should_receive('exist?').with(
        '/opt/antelope/5.4/bin/ald_proxy').and_return(true)
      File.should_receive('exist?').with(
        '/opt/antelope/5.4post/bin/ald_proxy').and_return(true)
      Facter::Antelope::AldProxyFact.add_facts
    end

    after :each do
      # Make sure we're clearing out Facter every time
      Facter.clear
      Facter.clear_messages
    end

    it { should_not be_nil }
    if a =~ /_array$/ then
      it { should eql(['5.4','5.4post']) }
    else
      it { should eql('5.4,5.4post') }
    end
  end
}
