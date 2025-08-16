# frozen_string_literal: true

require 'spec_helper'

describe 'test_version_compare' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it 'compiles without errors and uses antelope::version_compare function' do
        expect { catalogue }.not_to raise_error
        # This will fail if the function has syntax errors or doesn't load properly
        is_expected.to compile.with_all_deps
      end

      it 'creates the expected notify resources and executes successfully' do
        # Verify that the function calls work and produce the expected results
        is_expected.to contain_notify('version_compare_test_1_passed')
        is_expected.to contain_notify('version_compare_test_2_passed')
        is_expected.to contain_notify('version_compare_test_3_passed')
        # Test that the function actually executes during compilation without errors
        is_expected.to compile.with_all_deps
      end

      context 'with different version comparisons' do
        let(:pre_condition) do
          <<-PUPPET
            # Test additional version comparisons in pre_condition
            $test_result_1 = antelope::version_compare('5.2', '5.3')
            $test_result_2 = antelope::version_compare('5.5', '5.4')
            $test_result_3 = antelope::version_compare('5.5', '5.5')
          PUPPET
        end

        it 'handles version comparisons in pre_condition without syntax errors' do
          is_expected.to compile.with_all_deps
        end
      end
    end
  end
end
