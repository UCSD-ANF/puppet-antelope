require 'spec_helper'
require 'facter/antelope_latest_perl'

describe 'antelope_latest_perl fact', :type => :fact do
  let(:fact) { Facter.fact(:antelope_latest_perl) }
  subject(:antelope_latest_perl) { fact.value }

  before :each do
    Facter::Antelope::LatestPerl.add_facts
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end

  context 'with no Antelope installed' do
    it do
      expect(Facter.fact(:antelope_latest_version)).to receive(:value).\
        and_return(nil)
      expect(Facter::Antelope::LatestPerl).to_not receive(:getid)
      should be_nil
    end
  end

  context 'with a valid version specified' do
    it do
      expect(Facter.fact(:antelope_latest_version)).to receive(:value).\
        and_return('5.4')
      expect(Facter::Antelope::LatestPerl).to receive(:getid).with('5.4').\
        and_return('something')
      should eql('something')
    end
  end
  context 'with a invalid version specified' do
    it do
      expect(Facter.fact(:antelope_latest_version)).to receive(:value).\
        and_return('5.4')
      expect(Facter::Antelope::LatestPerl).to receive(:getid).with('5.4').\
        and_return(nil)
      should be_nil
    end
  end
end
