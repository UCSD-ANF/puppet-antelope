# frozen_string_literal: true

require 'spec_helper'
require 'facter/antelope_contrib_basedir'
require 'facter/util/antelope'

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

  before(:each) do
    Facter.clear
  end

  after(:each) do
    Facter.clear
  end

  describe 'contrib_subdir_exists?' do
    VERSION_DIRS.each do |version, dir_exists|
      context "with version #{version} and dir_exists #{dir_exists}" do
        it do
          expect(File).to receive(:directory?)\
            .with("/opt/antelope/#{version}/contrib/bin")\
            .and_return(dir_exists)
          expect(contrib_subdir_exists?(version)).to eq dir_exists
        end
      end
    end
  end

  describe 'antelope_contrib_basedir fact', type: :fact do
    subject(:antelope_contrib_basedir) { fact.value }

    let(:fact) { Facter.fact(:antelope_contrib_basedir) }

    context "with versions #{VERSION_DIRS.keys.join(', ')}" do
      before(:each) do
        allow(Facter::Util::Antelope).to receive(:versions).and_return(version_dirs.keys)
        allow(File).to receive(:directory?).and_call_original
        version_dirs.each do |version, dir_exists|
          allow(File).to receive(:directory?)\
            .with("/opt/antelope/#{version}/contrib/bin")\
            .and_return(dir_exists)
        end
      end

      it 'returns expected contrib basedirs' do
        is_expected.to eq(expected_contrib_basedir)
      end
    end
  end
end
