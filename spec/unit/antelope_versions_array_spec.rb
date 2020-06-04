require 'spec_helper'
require 'facter/antelope_versions'
require 'facter/util/antelope'

describe 'antelope_versions_array fact', type: :fact do
  subject(:antelope_versions_array) { fact.value }

  let(:fact) { Facter.fact(:antelope_versions_array) }

  before :each do
    allow(Facter::Util::Antelope).to receive(:versions)\
      .and_return([
                    '5.2-64', '5.4', '5.4post'
                  ])
    Facter::Antelope::Versions.add_facts
  end

  it { is_expected.to eql(['5.2-64', '5.4', '5.4post']) }
end
