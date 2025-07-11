# frozen_string_literal: true

require 'spec_helper'
require 'facter/antelope_versions_supports_aldproxy'
require 'facter/util/antelope'

['antelope_versions_supports_aldproxy', 'antelope_versions_supports_aldproxy_array'].each do |a|
  describe "#{a} fact", type: :fact do
    subject(a.to_sym) { fact.value }

    let(:fact) { Facter.fact(a.to_sym) }

    before :each do
      Facter.clear
      allow(Facter::Util::Antelope).to receive(:versions)\
        .and_return([
                      '5.2-64', '5.4', '5.4post'
                    ]).at_least(:once)
      allow(File).to receive('exist?').with(
        '/opt/antelope/5.2-64/bin/ald_proxy',
      ).and_return(false).at_least(:once)
      allow(File).to receive('exist?').with(
        '/opt/antelope/5.4/bin/ald_proxy',
      ).and_return(true).at_least(:once)
      allow(File).to receive('exist?').with(
        '/opt/antelope/5.4post/bin/ald_proxy',
      ).and_return(true).at_least(:once)
    end

    after :each do
      # Make sure we're clearing out Facter every time
      Facter.clear
      Facter.clear_messages
    end

    it { is_expected.not_to be_nil }
    if %r{_array$}.match?(a)
      it { is_expected.to eql(['5.4', '5.4post']) }
    else
      it { is_expected.to eql('5.4,5.4post') }
    end
  end
end
