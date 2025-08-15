# frozen_string_literal: true

require 'spec_helper'
require 'facter/antelope/contrib_basedir'
# require 'facter/util/antelope'
require 'byebug'

describe 'Antelope Contrib Basedir Specs' do
  VERSION_DIRS = { '5.2-64' => false, '5.4' => false, '5.4post' => true }.freeze
  let(:version_dirs) { VERSION_DIRS }
  let(:expected_contrib_basedir) do
    {
      '5.2-64' => '',
      '5.4' => '',
      '5.4post' => '/contrib',
    }
  end

  shared_context 'mocked contrib_subdir_exists?' do
    before(:each) do
      Facter.clear
      allow(Facter::Util::Antelope).to receive(:versions).and_return(version_dirs.keys).at_least(:once)
      version_dirs.each do |version, dir_exists|
        allow(Facter::Antelope::Contrib).to receive(:contrib_subdir_exists?)\
          .with(version).at_least(:once).and_return(dir_exists)
      end
    end
  end

  describe Facter::Antelope::Contrib do
    describe 'contrib_subdir_exists?' do
      VERSION_DIRS.each do |version, dir_exists|
        context "with version #{version} and dir_exists #{dir_exists}" do
          it do
            expect(File).to receive(:directory?)\
              .with("/opt/antelope/#{version}/contrib/bin")\
              .and_return(dir_exists)
            expect(described_class.contrib_subdir_exists?(version)).to eq dir_exists
          end
        end
      end
    end
    describe 'contrib_dirs' do
      context "with versions #{VERSION_DIRS.keys.join(', ')}" do
        include_context 'mocked contrib_subdir_exists?'

        it 'returns the expected contrib basedirs' do
          expect(described_class.contrib_dirs).to eq(expected_contrib_basedir)
        end
      end
    end
  end

  describe 'antelope_contrib_basedir fact', type: :fact do
    subject(:antelope_contrib_basedir) { fact.value }

    let(:fact) { Facter.fact(:antelope_contrib_basedir) }

    after(:each) { Facter.clear }

    context "with versions #{VERSION_DIRS.keys.join(', ')}" do
      include_context 'mocked contrib_subdir_exists?'

      it 'returns expected contrib basedirs' do
        skip('In test harness, Facter.fact hash.value with version numbers as keys is broken')
        is_expected.to eq(expected_contrib_basedir)
      end
    end
  end
end
