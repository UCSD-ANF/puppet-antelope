# frozen_string_literal: true

require 'spec_helper'
require 'facter/antelope_contrib_basedir'
# require 'facter/util/antelope'
require 'byebug'

describe 'Antelope Contrib Basedir Specs' do
  let(:version_dirs) { { '5.2-64' => false, '5.4' => false, '5.4post' => true } }
  let(:expected_contrib_basedir) do
    {
      '5.2-64' => '',
      '5.4' => '',
      '5.4post' => '/contrib',
    }
  end

  describe Facter::Antelope::Contrib do
    context 'with versions == 5.2-64, 5.4, 5.4post' do
      before(:each) do
        allow(Facter::Util::Antelope).to receive(:versions).and_return(version_dirs.keys)
        version_dirs.each do |version, dir_exists|
          allow(File).to receive(:directory?)\
            .with("/opt/antelope/#{version}/contrib/bin")\
            .and_return(dir_exists)
        end
      end

      it 'returns the expected contrib basedirs' do
        expect(described_class.contrib_dirs).to eq(expected_contrib_basedir)
      end
    end
  end

  describe 'antelope_contrib_basedir', type: :fact do
    before(:each) { Facter.clear }
    after(:each) { Facter.clear }

    context 'when versions == 5.2-64, 5.4, 5.4post' do
      before(:each) do
        allow(Facter::Util::Antelope).to receive(:versions).and_return(version_dirs.keys).at_least(:once)
        version_dirs.each do |version, dir_exists|
          allow(Facter::Antelope::Contrib).to receive(:contrib_subdir_exists?)\
            .with(version).at_least(:once).and_return(dir_exists)
        end
        Facter::Antelope::Contrib.add_facts
      end

      it 'returns expected contrib basedirs' do
        skip("facter fact testing doesn't work in PDK 1.1.18")
        expect(Facter.fact(:antelope_contrib_basedir).value).to eq(expected_contrib_basedir)
      end
    end
  end
end
