require 'spec_helper'
require 'facter/antelope_contrib_basedir'
require 'facter/util/antelope'

describe 'antelope_contrib_basedir fact', :type => :fact do
  let(:fact) { Facter.fact(:antelope_contrib_basedir) }
  subject(:antelope_contrib_basedir) { fact.value }

  before :each do
    Facter::Util::Antelope.should_receive(:get_versions).and_return([
      '5.2-64', '5.4', '5.4post'])
    File.should_receive('directory?').with(
      '/opt/antelope/5.2-64/contrib/bin').and_return(false)
    File.should_receive('directory?').with(
      '/opt/antelope/5.4/contrib/bin').and_return(false)
    File.should_receive('directory?').with(
      '/opt/antelope/5.4post/contrib/bin').and_return(true)
    Facter::Antelope::ContribFact.add_facts
  end

  after :each do
    # Make sure we're clearing out Facter every time
    Facter.clear
    Facter.clear_messages
  end

  it { should_not be_nil }
  it { should eql({
    '5.2-64' => '',
    '5.4' => '',
    '5.4post' => '/contrib', })
  }
end

