require 'spec_helper'
require 'facter/antelope_versions'
require 'facter/util/antelope'

describe 'Antelope Version Facts' do
  let(:test_versions) { ['5.2-64', '5.4', '5.4post'] }

  shared_context 'mocked versions' do
    before :each do
      Facter.clear
      allow(Facter::Util::Antelope).to receive(:versions)\
        .and_return(test_versions).at_least(:once)
    end
  end

  describe 'antelope_versions fact', type: :fact do
    subject(:antelope_versions) { fact.value }

    let(:fact) { Facter.fact(:antelope_versions) }
    let(:expected_versions) { test_versions.join(',') }

    include_context 'mocked versions'

    it { is_expected.to eql(expected_versions) }
  end

  describe 'antelope_versions_array fact', type: :fact do
    subject(:antelope_versions_array) { fact.value }

    let(:fact) { Facter.fact(:antelope_versions_array) }
    let(:expected_versions) { test_versions }

    include_context 'mocked versions'

    it { is_expected.to eql(expected_versions) }
  end
end
