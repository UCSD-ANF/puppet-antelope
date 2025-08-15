# frozen_string_literal: true

require 'spec_helper'
require 'facter/util/antelope'

describe Facter::Util::Antelope do
  before(:each) do
    Facter.clear
  end
  after(:each) { Facter.clear }

  describe '.parse_antelope_version' do
    it 'parses standard version correctly' do
      result = described_class.parse_antelope_version('5.4')
      expect(result).to eq({
                             major: 5,
        minor: 4,
        bit_suffix: nil,
        suffix: nil
                           })
    end

    it 'parses version with suffix correctly' do
      result = described_class.parse_antelope_version('5.4pre')
      expect(result).to eq({
                             major: 5,
        minor: 4,
        bit_suffix: nil,
        suffix: 'pre'
                           })
    end

    it 'parses version with bit suffix correctly' do
      result = described_class.parse_antelope_version('5.4-64')
      expect(result).to eq({
                             major: 5,
        minor: 4,
        bit_suffix: '-64',
        suffix: nil
                           })
    end

    it 'parses version with both suffixes correctly' do
      result = described_class.parse_antelope_version('5.4-64pre')
      expect(result).to eq({
                             major: 5,
        minor: 4,
        bit_suffix: '-64',
        suffix: 'pre'
                           })
    end

    it 'handles version that does not match regex' do
      result = described_class.parse_antelope_version('invalid')
      expect(result).to eq({
                             major: 0,
        minor: 0,
        bit_suffix: nil,
        suffix: nil
                           })
    end
  end

  describe '.compare_suffixes' do
    it 'returns 0 for identical suffixes' do
      expect(described_class.compare_suffixes('pre', 'pre')).to eq(0)
      expect(described_class.compare_suffixes(nil, nil)).to eq(0)
      expect(described_class.compare_suffixes('post', 'post')).to eq(0)
      expect(described_class.compare_suffixes('p', 'p')).to eq(0)
    end

    it 'returns 1 when first suffix is nil (release > pre-release)' do
      expect(described_class.compare_suffixes(nil, 'pre')).to eq(1)
    end

    it 'returns -1 when second suffix is nil (pre-release < release)' do
      expect(described_class.compare_suffixes('pre', nil)).to eq(-1)
    end

    it 'handles pre suffix correctly' do
      expect(described_class.compare_suffixes('pre', 'post')).to eq(-1)
      expect(described_class.compare_suffixes('pre', 'p')).to eq(-1)
      expect(described_class.compare_suffixes('post', 'pre')).to eq(1)
      expect(described_class.compare_suffixes('p', 'pre')).to eq(1)
    end

    it 'treats post and p as equivalent and greater than no suffix' do
      expect(described_class.compare_suffixes('post', nil)).to eq(1)
      expect(described_class.compare_suffixes('p', nil)).to eq(1)
      expect(described_class.compare_suffixes(nil, 'post')).to eq(-1)
      expect(described_class.compare_suffixes(nil, 'p')).to eq(-1)
    end
  end

  describe '.compare_bit_suffixes' do
    it 'returns 0 for identical bit suffixes' do
      expect(described_class.compare_bit_suffixes('-64', '-64', 5, 4)).to eq(0)
      expect(described_class.compare_bit_suffixes(nil, nil, 5, 4)).to eq(0)
    end

    context 'during transition period (before 5.5)' do
      it 'returns -1 when first is 32-bit and second is 64-bit' do
        expect(described_class.compare_bit_suffixes(nil, '-64', 5, 4)).to eq(-1)
        expect(described_class.compare_bit_suffixes(nil, '-64', 5, 2)).to eq(-1)
        expect(described_class.compare_bit_suffixes(nil, '-64', 4, 11)).to eq(-1)
      end

      it 'returns 1 when first is 64-bit and second is 32-bit' do
        expect(described_class.compare_bit_suffixes('-64', nil, 5, 4)).to eq(1)
        expect(described_class.compare_bit_suffixes('-64', nil, 5, 2)).to eq(1)
        expect(described_class.compare_bit_suffixes('-64', nil, 4, 11)).to eq(1)
      end
    end

    context 'post-transition period (5.5+)' do
      it 'returns 1 when first has no suffix (newer) and second has -64 (older)' do
        expect(described_class.compare_bit_suffixes(nil, '-64', 5, 5)).to eq(1)
        expect(described_class.compare_bit_suffixes(nil, '-64', 5, 6)).to eq(1)
        expect(described_class.compare_bit_suffixes(nil, '-64', 6, 0)).to eq(1)
      end

      it 'returns -1 when first has -64 (older) and second has no suffix (newer)' do
        expect(described_class.compare_bit_suffixes('-64', nil, 5, 5)).to eq(-1)
        expect(described_class.compare_bit_suffixes('-64', nil, 5, 6)).to eq(-1)
        expect(described_class.compare_bit_suffixes('-64', nil, 6, 0)).to eq(-1)
      end
    end
  end

  describe '.compare_antelope_versions' do
    it 'returns 0 for identical versions' do
      expect(described_class.compare_antelope_versions('5.4', '5.4')).to eq(0)
      expect(described_class.compare_antelope_versions('5.4pre', '5.4pre')).to eq(0)
      expect(described_class.compare_antelope_versions('5.4-64', '5.4-64')).to eq(0)
    end

    it 'compares major versions first' do
      expect(described_class.compare_antelope_versions('5.3', '6.0')).to eq(-1)
      expect(described_class.compare_antelope_versions('6.0', '5.3')).to eq(1)
    end

    it 'compares minor versions when major versions are equal' do
      expect(described_class.compare_antelope_versions('5.3', '5.4')).to eq(-1)
      expect(described_class.compare_antelope_versions('5.4', '5.3')).to eq(1)
      expect(described_class.compare_antelope_versions('5.10', '5.2')).to eq(1)
    end

    it 'compares suffixes when base versions are equal' do
      expect(described_class.compare_antelope_versions('5.4pre', '5.4')).to eq(-1)
      expect(described_class.compare_antelope_versions('5.4', '5.4pre')).to eq(1)
      expect(described_class.compare_antelope_versions('5.4', '5.4post')).to eq(-1)
      expect(described_class.compare_antelope_versions('5.4post', '5.4')).to eq(1)
    end

    it 'compares bit suffixes when base versions and suffixes are equal' do
      # During transition period
      expect(described_class.compare_antelope_versions('5.4', '5.4-64')).to eq(-1)
      expect(described_class.compare_antelope_versions('5.4-64', '5.4')).to eq(1)

      # Post-transition period
      expect(described_class.compare_antelope_versions('5.5-64', '5.5')).to eq(-1)
      expect(described_class.compare_antelope_versions('5.5', '5.5-64')).to eq(1)
    end

    it 'handles complex version comparisons correctly' do
      expect(described_class.compare_antelope_versions('5.4pre', '5.4post')).to eq(-1)
      expect(described_class.compare_antelope_versions('5.3post', '5.4pre')).to eq(-1)
      expect(described_class.compare_antelope_versions('5.4-64pre', '5.4pre')).to eq(1)
    end
  end

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

    context 'bit suffix bug fix verification' do
      context '5.4 vs 5.4-64 (transition period)' do
        let(:a) { '5.4' }
        let(:b) { '5.4-64' }

        it 'returns -1 (32-bit < 64-bit during transition)' do
          expect(data).to eq(-1)
        end
      end

      context '5.4-64 vs 5.4 (transition period)' do
        let(:a) { '5.4-64' }
        let(:b) { '5.4' }

        it 'returns 1 (64-bit > 32-bit during transition)' do
          expect(data).to eq(1)
        end
      end

      context '5.5-64 vs 5.5 (post-transition period)' do
        let(:a) { '5.5-64' }
        let(:b) { '5.5' }

        it 'returns -1 (old 64-bit < new default 64-bit)' do
          expect(data).to eq(-1)
        end
      end
    end
  end

  # Cross-validation tests with Puppet function
  describe 'cross-validation with Puppet function' do
    let(:test_version_pairs) do
      [
        ['5.3', '5.4'],
        ['5.4pre', '5.4'],
        ['5.4', '5.4-64'],
        ['5.4pre', '5.4post'],
        ['5.10', '5.2'],
        ['5.4', '5.4'],
        ['5.3post', '5.4pre'],
        ['5.2-64', '5.2-64p'],
        ['5.5', '5.5-64'],
        ['5.4-64', '5.4'],
      ]
    end

    it 'produces results consistent with expected Antelope version ordering' do
      test_version_pairs.each do |version_a, version_b|
        facter_result = described_class.compare_antelope_versions(version_a, version_b)

        # Test that the comparison is consistent (if a < b, then b > a)
        reverse_result = described_class.compare_antelope_versions(version_b, version_a)
        expect(facter_result).to eq(-reverse_result),
          "Inconsistent comparison for #{version_a} vs #{version_b}: " \
          "forward=#{facter_result}, reverse=#{reverse_result}"
      end
    end

    it 'sorts complex version sets correctly' do
      versions = ['5.5', '5.4-64', '5.4pre', '5.4', '5.3', '5.2-64', '5.4post', '5.2-64p']
      expected_order = ['5.2-64', '5.2-64p', '5.3', '5.4pre', '5.4', '5.4post', '5.4-64', '5.5']

      sorted_versions = versions.sort { |a, b| described_class.compare_antelope_versions(a, b) }
      expect(sorted_versions).to eq(expected_order)
    end

    it 'maintains transitivity property' do
      # Test a < b and b < c implies a < c
      versions = ['5.3', '5.4pre', '5.4', '5.4post', '5.5']

      (0...versions.length - 2).each do |i|
        a = versions[i]
        b = versions[i + 1]
        c = versions[i + 2]

        ab_result = described_class.compare_antelope_versions(a, b)
        bc_result = described_class.compare_antelope_versions(b, c)
        ac_result = described_class.compare_antelope_versions(a, c)

        if ab_result <= 0 && bc_result <= 0
          expect(ac_result).to be <= 0,
            "Transitivity violation: #{a} <= #{b} <= #{c} but #{a} not <= #{c}"
        end
      end
    end
  end

  describe 'integration with existing functionality' do
    before(:each) do
      allow(Dir).to receive(:exist?).with('/opt/antelope').and_return(true)
      allow(Dir).to receive(:entries).with('/opt/antelope').and_return([
                                                                         '.',
                                                                         '..',
                                                                         '5.3',
                                                                         '5.2-64',
                                                                         '5.4pre',
                                                                         '5.4',
                                                                         '5.5',
                                                                         'invalid-dir',
                                                                       ])

      # Mock File.exist? for setup.sh files
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?).with('/opt/antelope/5.3/setup.sh').and_return(true)
      allow(File).to receive(:exist?).with('/opt/antelope/5.2-64/setup.sh').and_return(true)
      allow(File).to receive(:exist?).with('/opt/antelope/5.4pre/setup.sh').and_return(true)
      allow(File).to receive(:exist?).with('/opt/antelope/5.4/setup.sh').and_return(true)
      allow(File).to receive(:exist?).with('/opt/antelope/5.5/setup.sh').and_return(true)
    end

    describe '.versions' do
      it 'returns sorted versions using new comparison logic' do
        expected = ['5.2-64', '5.3', '5.4pre', '5.4', '5.5']
        expect(described_class.versions).to eq(expected)
      end
    end
  end
end
