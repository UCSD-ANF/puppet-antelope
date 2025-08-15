# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::version_compare function Puppet integration' do
  # This test ensures the function loads and works correctly, solving the original syntax error

  context 'Function loading and syntax' do
    it 'loads successfully without syntax errors' do
      # This was failing before with "Syntax error at ':'" in Puppet 8.10.0
      # The main goal is that this doesn't raise an error anymore
      expect {
        require_relative '../../../lib/puppet/functions/antelope/version_compare.rb'
      }.not_to raise_error

      # Verify the shared utility module is accessible
      expect(defined?(Antelope::VersionUtils)).to be_truthy
    end

    it 'shared utility module loads successfully' do
      # Load the utility directly to verify it works
      expect {
        require_relative '../../../lib/antelope/version_utils.rb'
      }.not_to raise_error

      # Verify the module exists
      expect(defined?(Antelope::VersionUtils)).to be_truthy
    end
  end

  context 'Function file syntax and structure' do
    it 'function file contains correct require path' do
      # Read the function file and verify it has the correct require path
      function_content = File.read('lib/puppet/functions/antelope/version_compare.rb')

      # Should contain the corrected require_relative path
      expect(function_content).to include("require_relative '../../../antelope/version_utils'")

      # Should NOT contain the invalid include statement
      expect(function_content).not_to include('include Antelope::VersionUtils')

      # Should contain the correct module call
      expect(function_content).to include('compare_antelope_versions')
    end

    it 'function file can be parsed by Ruby without syntax errors' do
      # This is the core test - the file should parse correctly
      expect {
        load 'lib/puppet/functions/antelope/version_compare.rb'
      }.not_to raise_error
    end
  end
end
