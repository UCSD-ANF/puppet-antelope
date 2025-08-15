# frozen_string_literal: true

require 'spec_helper'
require 'antelope/version_utils'

describe Antelope::VersionUtils do
  let(:test_class) { Class.new { include Antelope::VersionUtils } }
  let(:instance) { test_class.new }

  describe '.parse_antelope_version' do
    it 'parses standard version correctly' do
      result = instance.parse_antelope_version('5.4')
      expect(result).to eq({
                             major: 5,
                             minor: 4,
                             bit_suffix: nil,
                             suffix: nil
                           })
    end

    it 'parses version with pre suffix correctly' do
      result = instance.parse_antelope_version('5.4pre')
      expect(result).to eq({
                             major: 5,
                             minor: 4,
                             bit_suffix: nil,
                             suffix: 'pre'
                           })
    end

    it 'parses version with post suffix correctly' do
      result = instance.parse_antelope_version('5.4post')
      expect(result).to eq({
                             major: 5,
                             minor: 4,
                             bit_suffix: nil,
                             suffix: 'post'
                           })
    end

    it 'parses version with p suffix correctly' do
      result = instance.parse_antelope_version('4.11p')
      expect(result).to eq({
                             major: 4,
                             minor: 11,
                             bit_suffix: nil,
                             suffix: 'p'
                           })
    end

    it 'parses version with bit suffix correctly' do
      result = instance.parse_antelope_version('5.4-64')
      expect(result).to eq({
                             major: 5,
                             minor: 4,
                             bit_suffix: '-64',
                             suffix: nil
                           })
    end

    it 'handles version that does not match regex' do
      result = instance.parse_antelope_version('invalid')
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
      expect(instance.compare_suffixes('pre', 'pre')).to eq(0)
      expect(instance.compare_suffixes(nil, nil)).to eq(0)
      expect(instance.compare_suffixes('post', 'post')).to eq(0)
      expect(instance.compare_suffixes('p', 'p')).to eq(0)
    end

    it 'handles pre suffix as lowest priority' do
      expect(instance.compare_suffixes('pre', nil)).to eq(-1)
      expect(instance.compare_suffixes(nil, 'pre')).to eq(1)
      expect(instance.compare_suffixes('pre', 'post')).to eq(-1)
      expect(instance.compare_suffixes('pre', 'p')).to eq(-1)
    end

    it 'treats post and p as equivalent and greater than no suffix' do
      expect(instance.compare_suffixes('post', nil)).to eq(1)
      expect(instance.compare_suffixes('p', nil)).to eq(1)
      expect(instance.compare_suffixes(nil, 'post')).to eq(-1)
      expect(instance.compare_suffixes(nil, 'p')).to eq(-1)
      expect(instance.compare_suffixes('post', 'p')).to eq(0)
      expect(instance.compare_suffixes('p', 'post')).to eq(0)
    end
  end

  describe '.compare_bit_suffixes' do
    it 'returns 0 for identical bit suffixes' do
      expect(instance.compare_bit_suffixes('-64', '-64', 5, 4)).to eq(0)
      expect(instance.compare_bit_suffixes(nil, nil, 5, 4)).to eq(0)
    end

    context 'during transition period (before 5.5)' do
      it 'treats -64 as newer than no suffix' do
        expect(instance.compare_bit_suffixes(nil, '-64', 5, 4)).to eq(-1)
        expect(instance.compare_bit_suffixes('-64', nil, 5, 4)).to eq(1)
        expect(instance.compare_bit_suffixes(nil, '-64', 4, 11)).to eq(-1)
        expect(instance.compare_bit_suffixes('-64', nil, 4, 11)).to eq(1)
      end
    end

    context 'post-transition period (5.5+)' do
      it 'treats no suffix as newer than -64' do
        expect(instance.compare_bit_suffixes(nil, '-64', 5, 5)).to eq(1)
        expect(instance.compare_bit_suffixes('-64', nil, 5, 5)).to eq(-1)
        expect(instance.compare_bit_suffixes(nil, '-64', 5, 6)).to eq(1)
        expect(instance.compare_bit_suffixes('-64', nil, 5, 6)).to eq(-1)
        expect(instance.compare_bit_suffixes(nil, '-64', 6, 0)).to eq(1)
        expect(instance.compare_bit_suffixes('-64', nil, 6, 0)).to eq(-1)
      end
    end
  end

  describe '.compare_antelope_versions' do
    it 'returns 0 for identical versions' do
      expect(instance.compare_antelope_versions('5.4', '5.4')).to eq(0)
      expect(instance.compare_antelope_versions('5.4pre', '5.4pre')).to eq(0)
      expect(instance.compare_antelope_versions('5.4-64', '5.4-64')).to eq(0)
    end

    it 'compares major versions first' do
      expect(instance.compare_antelope_versions('4.9', '5.1')).to eq(-1)
      expect(instance.compare_antelope_versions('5.1', '4.9')).to eq(1)
    end

    it 'compares minor versions when major versions are equal' do
      expect(instance.compare_antelope_versions('5.1', '5.2')).to eq(-1)
      expect(instance.compare_antelope_versions('5.2', '5.1')).to eq(1)
      expect(instance.compare_antelope_versions('5.10', '5.2')).to eq(1)
    end

    it 'compares bit suffixes when base versions are equal' do
      # During transition period (before 5.5)
      expect(instance.compare_antelope_versions('5.4', '5.4-64')).to eq(-1)
      expect(instance.compare_antelope_versions('5.4-64', '5.4')).to eq(1)

      # Post-transition period (5.5+)
      expect(instance.compare_antelope_versions('5.5-64', '5.5')).to eq(-1)
      expect(instance.compare_antelope_versions('5.5', '5.5-64')).to eq(1)
    end

    it 'compares suffixes when base versions and bit suffixes are equal' do
      expect(instance.compare_antelope_versions('5.4pre', '5.4')).to eq(-1)
      expect(instance.compare_antelope_versions('5.4', '5.4pre')).to eq(1)
      expect(instance.compare_antelope_versions('5.4', '5.4post')).to eq(-1)
      expect(instance.compare_antelope_versions('5.4post', '5.4')).to eq(1)
      expect(instance.compare_antelope_versions('5.4pre', '5.4post')).to eq(-1)
      expect(instance.compare_antelope_versions('5.4post', '5.4pre')).to eq(1)
    end

    it 'handles complex version comparisons correctly' do
      expect(instance.compare_antelope_versions('5.3post', '5.4pre')).to eq(-1)
      expect(instance.compare_antelope_versions('5.2-64', '5.2-64p')).to eq(-1)
      expect(instance.compare_antelope_versions('5.4-64pre', '5.4pre')).to eq(1)
    end
  end

  describe '.sort_antelope_versions' do
    it 'sorts versions correctly using Antelope comparison logic' do
      versions = ['5.5', '5.4-64', '5.4pre', '5.4', '5.3', '5.2-64', '5.4post', '5.2-64p']
      expected_order = ['5.2-64', '5.2-64p', '5.3', '5.4pre', '5.4', '5.4post', '5.4-64', '5.5']

      sorted_versions = instance.sort_antelope_versions(versions)
      expect(sorted_versions).to eq(expected_order)
    end

    it 'handles empty array' do
      expect(instance.sort_antelope_versions([])).to eq([])
    end

    it 'handles single version' do
      expect(instance.sort_antelope_versions(['5.4'])).to eq(['5.4'])
    end
  end

  describe 'consistency and mathematical properties' do
    let(:test_versions) do
      ['5.2-64', '5.2-64p', '5.3pre', '5.3', '5.3post', '5.4pre', '5.4', '5.4-64', '5.4post', '5.5', '5.5-64', '5.6']
    end

    it 'maintains antisymmetric property' do
      test_versions.each do |version_a|
        test_versions.each do |version_b|
          result_ab = instance.compare_antelope_versions(version_a, version_b)
          result_ba = instance.compare_antelope_versions(version_b, version_a)

          expect(result_ab).to eq(-result_ba),
                                 "Antisymmetric property failed for #{version_a} vs #{version_b}: " \
                                 "ab=#{result_ab}, ba=#{result_ba}"
        end
      end
    end

    it 'maintains transitive property' do
      (0...test_versions.length - 2).each do |i|
        version_a = test_versions[i]
        version_b = test_versions[i + 1]
        version_c = test_versions[i + 2]

        ab_result = instance.compare_antelope_versions(version_a, version_b)
        bc_result = instance.compare_antelope_versions(version_b, version_c)
        ac_result = instance.compare_antelope_versions(version_a, version_c)

        next unless ab_result <= 0 && bc_result <= 0
        expect(ac_result).to be <= 0,
                             "Transitivity violation: #{version_a} <= #{version_b} <= #{version_c} " \
                             "but #{version_a} not <= #{version_c} (#{ac_result})"
      end
    end

    it 'maintains reflexive property' do
      test_versions.each do |version|
        expect(instance.compare_antelope_versions(version, version)).to eq(0),
                                                                          "Reflexive property failed for #{version}"
      end
    end
  end

  describe 'regular expression validation' do
    it 'correctly identifies valid version patterns' do
      valid_versions = ['4.9', '5.0', '5.1', '5.1-64', '4.9pre', '4.9post', '4.11p', '5.2-64p']
      valid_versions.each do |version|
        expect(Antelope::VersionUtils::RE_VERSION.match(version)).not_to be_nil,
                                                                      "Version #{version} should match regex"
      end
    end

    it 'correctly rejects invalid version patterns' do
      invalid_versions = ['4', '4.9.1', 'v5.1', '5.1-32', '5.1beta', '5.1-64-pre']
      invalid_versions.each do |version|
        expect(Antelope::VersionUtils::RE_VERSION.match(version)).to be_nil,
                                                                     "Version #{version} should not match regex"
      end
    end
  end

  describe 'error handling' do
    it 'raises ArgumentError for invalid version formats in comparison' do
      expect { instance.compare_antelope_versions('invalid', '5.1') }
        .to raise_error(ArgumentError, %r{Invalid Antelope version format: 'invalid'})

      expect { instance.compare_antelope_versions('5.1', 'also-invalid') }
        .to raise_error(ArgumentError, %r{Invalid Antelope version format: 'also-invalid'})
    end

    it 'does not raise error for valid version formats' do
      expect { instance.compare_antelope_versions('5.1', '5.2') }.not_to raise_error
      expect { instance.compare_antelope_versions('4.9pre', '4.9post') }.not_to raise_error
      expect { instance.compare_antelope_versions('5.1-64', '5.2') }.not_to raise_error
    end

    it 'raises ArgumentError for invalid versions in sorting' do
      expect { instance.sort_antelope_versions(['5.1', 'invalid', '5.2']) }
        .to raise_error(ArgumentError, %r{Invalid Antelope version format: 'invalid'})
    end
  end
end
