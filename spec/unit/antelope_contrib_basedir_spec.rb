# frozen_string_literal: true

require 'spec_helper'
require 'facter/antelope_contrib_basedir'
require 'facter/util/antelope'

describe 'antelope_contrib_basedir fact', type: :fact do
  subject(:antelope_contrib_basedir) { fact.value }

  let(:fact) { Facter.fact(:antelope_contrib_basedir) }

  before :each do
    expect(Facter::Util::Antelope).to receive(:get_versions).and_return([
                                                                          '5.2-64', '5.4', '5.4post'
                                                                        ])
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with(
      '/opt/antelope/5.2-64/confrib/bin',
    ).and_return(false)
    allow(File).to receive(:directory?).with(
      '/opt/antelope/5.4/contrib/bin',
    ).and_return(false)
    allow(File).to receive(:directory?).with(
      '/opt/antelope/5.4post/contrib/bin',
    ).and_return(true)
    Facter::Antelope::ContribFact.add_facts
  end

  it { is_expected.not_to be_nil }
  it {
    is_expected.to eql(
      '5.2-64' => '',
      '5.4' => '',
      '5.4post' => '/contrib',
    )
  }

  after :each do
    # Make sure we're clearing out Facter every time
    Facter.clear
    Facter.clear_messages
  end
end
