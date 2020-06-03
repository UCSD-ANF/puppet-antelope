# frozen_string_literal: true

require 'spec_helper'
require 'facter/util/antelope'

describe Facter::Util::Antelope do
  before(:each) do
    Facter.clear
  end
  after(:each) { Facter.clear }

  describe '.sort_versions' do
    subject(:data) { described_class.sort_versions(a, b) }

    context 'equal 64-bit versions' do
      let(:a) { '5.2-64' }
      let(:b) { '5.2-64' }

      it { is_expected.to eq 0 }
    end
    context 'equal unadorned versions' do
      let(:a) { '5.3' }
      let(:b) { '5.3' }

      it { is_expected.to eq(0) }
    end
    context 'equal pre versions' do
      let(:a) { '5.3pre' }
      let(:b) { '5.3pre' }

      it { is_expected.to eq(0) }
    end
    context 'equal post versions' do
      let(:a) { '5.3post' }
      let(:b) { '5.3post' }

      it { is_expected.to eq(0) }
    end
    context 'equal p versions' do
      let(:a) { '4.11p' }
      let(:b) { '4.11p' }

      it { is_expected.to eq(0) }
    end
    context '5.2-64 and 5.2-64p' do
      let(:a) { '5.2-64' }
      let(:b) { '5.2-64p' }

      it { is_expected.to eq(-1) }
    end
    context '5.2-64p and 5.2-64' do
      let(:a) { '5.2-64p' }
      let(:b) { '5.2-64' }

      it { is_expected.to eq(1) }
    end
    context '5.3pre and 5.3post' do
      let(:a) { '5.3pre' }
      let(:b) { '5.3post' }

      it { is_expected.to eq(-1) }
    end
    context '5.3post and 5.3pre' do
      let(:a) { '5.3post' }
      let(:b) { '5.3pre' }

      it { is_expected.to eq(1) }
    end
    context '5.3post and 5.4pre' do
      let(:a) { '5.3post' }
      let(:b) { '5.4pre' }

      it { is_expected.to eq(-1) }
    end
    context '5.4pre and 5.3post' do
      let(:a) { '5.4pre' }
      let(:b) { '5.3post' }

      it { is_expected.to eq(1) }
    end
  end
end
