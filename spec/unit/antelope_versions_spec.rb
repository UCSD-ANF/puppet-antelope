require 'spec_helper'
require 'facter/antelope_versions'
require 'facter/util/antelope'

describe 'antelope_versions fact', :type => :fact do
  let(:fact) { Facter.fact(:antelope_versions) }
  subject(:antelope_versions) { fact.value }

  before :each do
    expect(Facter::Util::Antelope).to receive(:get_versions).and_return([
      '5.2-64', '5.4', '5.4post'])
    Facter::Antelope::Versions.add_facts
  end

  it { should eql('5.2-64,5.4,5.4post') }
end
describe 'antelope_versions_array fact', :type => :fact do
  let(:fact) { Facter.fact(:antelope_versions_array) }
  subject(:antelope_versions_array) { fact.value }

  before :each do
    expect(Facter::Util::Antelope).to receive(:get_versions).and_return([
      '5.2-64', '5.4', '5.4post'])
    Facter::Antelope::Versions.add_facts
  end

  it { should eql(['5.2-64','5.4','5.4post']) }
end
