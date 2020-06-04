# frozen_string_literal: true

require 'spec_helper'
require 'facter/antelope_latest'

describe 'antelope_latest_perl fact', type: :fact do
  subject(:antelope_latest_perl) { fact.value }

  let(:fact) { Facter.fact(:antelope_latest_perl) }

  before :each do
    Facter.clear
    Facter::Antelope::Latest.add_facts
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end

  context 'with no Antelope installed' do
    it do
      expect(Facter.fact(:antelope_latest_version)).to receive(:value)\
        .and_return(nil).at_least(:once)
      expect(Facter::Util::Antelope).not_to receive(:getid)
      is_expected.to be_nil
    end
  end

  context 'with a valid version specified' do
    it do
      expect(Facter.fact(:antelope_latest_version)).to receive(:value)\
        .and_return('5.4').at_least(:once)
      expect(Facter::Util::Antelope).to receive(:getid)\
        .with('5.4', :perl)\
        .and_return('something').at_least(:once)
      is_expected.to eql('something')
    end
  end
  context 'with a invalid version specified' do
    it do
      expect(Facter.fact(:antelope_latest_version)).to receive(:value)\
        .and_return('5.4').at_least(:once)
      expect(Facter::Util::Antelope).to receive(:getid)\
        .with('5.4', :perl)\
        .and_return(nil).at_least(:once)
      is_expected.to be_nil
    end
  end
end
