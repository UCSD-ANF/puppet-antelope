# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::version_compare' do
  it 'returns 0 for identical versions' do
    is_expected.to run.with_params('5.1', '5.1').and_return(0)
    is_expected.to run.with_params('4.9pre', '4.9pre').and_return(0)
    is_expected.to run.with_params('5.1-64', '5.1-64').and_return(0)
  end

  describe 'basic version comparison' do
    it 'compares major versions correctly' do
      is_expected.to run.with_params('4.9', '5.1').and_return(-1)
      is_expected.to run.with_params('5.1', '4.9').and_return(1)
    end

    it 'compares minor versions correctly' do
      is_expected.to run.with_params('5.1', '5.2').and_return(-1)
      is_expected.to run.with_params('5.2', '5.1').and_return(1)
    end
  end

  describe 'pre/post/p suffix handling' do
    it 'handles pre suffix correctly' do
      is_expected.to run.with_params('4.9pre', '4.9').and_return(-1)
      is_expected.to run.with_params('4.9', '4.9pre').and_return(1)
    end

    it 'handles post suffix correctly' do
      is_expected.to run.with_params('4.9', '4.9post').and_return(-1)
      is_expected.to run.with_params('4.9post', '4.9').and_return(1)
    end

    it 'handles p suffix correctly' do
      is_expected.to run.with_params('4.11', '4.11p').and_return(-1)
      is_expected.to run.with_params('4.11p', '4.11').and_return(1)
    end

    it 'orders pre/post/p correctly' do
      is_expected.to run.with_params('4.9pre', '4.9post').and_return(-1)
      is_expected.to run.with_params('4.9post', '4.9pre').and_return(1)
      is_expected.to run.with_params('4.9pre', '4.9p').and_return(-1)
    end

    it 'handles pre/post with version differences' do
      is_expected.to run.with_params('4.9post', '4.10').and_return(-1)
      is_expected.to run.with_params('4.10', '4.9post').and_return(1)
      is_expected.to run.with_params('4.8post', '4.9pre').and_return(-1)
    end
  end

  describe '64-bit transition handling' do
    it 'handles 5.5 vs 5.1-64 correctly (post-transition)' do
      # 5.5 (64-bit only) should be newer than 5.1-64 (transition period)
      is_expected.to run.with_params('5.1-64', '5.5').and_return(-1)
      is_expected.to run.with_params('5.5', '5.1-64').and_return(1)
    end

    it 'handles same version during transition period' do
      # During transition: 5.1 (32-bit) < 5.1-64 (64-bit)
      is_expected.to run.with_params('5.1', '5.1-64').and_return(-1)
      is_expected.to run.with_params('5.1-64', '5.1').and_return(1)
    end

    it 'handles different 64-bit versions correctly' do
      is_expected.to run.with_params('5.1-64', '5.2-64').and_return(-1)
      is_expected.to run.with_params('5.2-64', '5.1-64').and_return(1)
    end

    it 'handles post-transition versions (5.5+)' do
      # 5.6 should be newer than 5.5-64 (if such existed)
      is_expected.to run.with_params('5.5-64', '5.6').and_return(-1)
      is_expected.to run.with_params('5.6', '5.5-64').and_return(1)
    end
  end

  describe 'complex scenarios matching existing test cases' do
    # These match the existing Facter::Util::Antelope test cases
    it 'handles 5.2-64 and 5.2-64p' do
      is_expected.to run.with_params('5.2-64', '5.2-64p').and_return(-1)
      is_expected.to run.with_params('5.2-64p', '5.2-64').and_return(1)
    end

    it 'handles 5.3pre and 5.3post' do
      is_expected.to run.with_params('5.3pre', '5.3post').and_return(-1)
      is_expected.to run.with_params('5.3post', '5.3pre').and_return(1)
    end

    it 'handles 5.3post and 5.4pre' do
      is_expected.to run.with_params('5.3post', '5.4pre').and_return(-1)
      is_expected.to run.with_params('5.4pre', '5.3post').and_return(1)
    end
  end

  describe 'realistic version progression' do
    it 'handles the expected version order' do
      versions = [
        '4.9pre',
        '4.9',
        '4.9post',
        '5.0',
        '5.1',
        '5.1-64',    # Transition period: 64-bit version of 5.1
        '5.2',
        '5.2-64',    # Transition period: 64-bit version of 5.2
        '5.2-64p',   # Patch for 64-bit 5.2
        '5.3pre',
        '5.3',
        '5.3post',
        '5.4pre',
        '5.4',
        '5.5',       # Post-transition: 64-bit only
        '5.6', # Post-transition: 64-bit only
      ]

      # Test that each version is less than the next
      (0...versions.length - 1).each do |i|
        is_expected.to run.with_params(versions[i], versions[i + 1]).and_return(-1)
      end
    end
  end

  describe 'error handling' do
    it 'raises error for invalid version format' do
      is_expected.to run.with_params('invalid', '5.1').and_raise_error(ArgumentError, %r{Invalid Antelope version format})
      is_expected.to run.with_params('5.1', 'also-invalid').and_raise_error(ArgumentError, %r{Invalid Antelope version format})
    end

    it 'handles edge cases' do
      # These should be valid according to the existing regex
      is_expected.to run.with_params('4.0', '4.1').and_return(-1)
      is_expected.to run.with_params('9.99', '9.100').and_return(-1)
    end
  end
end
