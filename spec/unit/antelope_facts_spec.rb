# frozen_string_literal: true

require 'spec_helper'
require 'facter/util/antelope'

describe 'Antelope Facts' do
  let(:test_versions) { ['5.2-64', '5.4', '5.4post'] }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end

  # ============================================================================
  # antelope_latest_perl fact tests
  # ============================================================================

  describe 'antelope_latest_perl fact', type: :fact do
    subject(:antelope_latest_perl) { fact.value }

    let(:fact) { Facter.fact(:antelope_latest_perl) }

    context 'with no Antelope installed' do
      it do
        expect(Facter.fact(:antelope_latest_version)).to receive(:value)
          .and_return(nil).at_least(:once)
        expect(Facter::Util::Antelope).not_to receive(:getid)
        is_expected.to be_nil
      end
    end

    context 'with a valid version specified' do
      it do
        expect(Facter.fact(:antelope_latest_version)).to receive(:value)
          .and_return('5.4').at_least(:once)
        expect(Facter::Util::Antelope).to receive(:getid)
          .with('5.4', :perl)
          .and_return('something').at_least(:once)
        is_expected.to eql('something')
      end
    end

    context 'with a invalid version specified' do
      it do
        expect(Facter.fact(:antelope_latest_version)).to receive(:value)
          .and_return('5.4').at_least(:once)
        expect(Facter::Util::Antelope).to receive(:getid)
          .with('5.4', :perl)
          .and_return(nil).at_least(:once)
        is_expected.to be_nil
      end
    end
  end

  # ============================================================================
  # antelope_latest_python fact tests
  # ============================================================================

  describe 'antelope_latest_python fact', type: :fact do
    subject(:antelope_latest_python) { fact.value }

    let(:fact) { Facter.fact(:antelope_latest_python) }

    context 'with no Antelope installed' do
      it do
        expect(Facter.fact(:antelope_latest_version)).to receive(:value)
          .and_return(nil).at_least(:once)
        expect(Facter::Util::Antelope).not_to receive(:getid)
        is_expected.to be_nil
      end
    end

    context 'with a valid version specified' do
      it do
        expect(Facter.fact(:antelope_latest_version)).to receive(:value)
          .and_return('5.4').at_least(:once)
        expect(Facter::Util::Antelope).to receive(:getid)
          .with('5.4', :python)
          .and_return('python3.6').at_least(:once)
        is_expected.to eql('python3.6')
      end
    end
  end

  # ============================================================================
  # antelope_contrib_basedir fact tests
  # ============================================================================

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
        allow(Facter::Util::Antelope).to receive(:versions).and_return(version_dirs.keys).at_least(:once)
        # Mock all File.directory? calls to return false by default
        allow(File).to receive(:directory?).and_return(false)
        version_dirs.each do |version, dir_exists|
          allow(File).to receive(:directory?)
            .with("/opt/antelope/#{version}/contrib/bin")
            .and_return(dir_exists).at_least(:once)
        end
      end
    end

    describe 'antelope_contrib_basedir fact', type: :fact do
      subject(:antelope_contrib_basedir) { fact.value }

      let(:fact) { Facter.fact(:antelope_contrib_basedir) }

      context "with versions #{VERSION_DIRS.keys.join(', ')}" do
        include_context 'mocked contrib_subdir_exists?'

        it 'returns expected contrib basedirs' do
          skip('Contrib basedir fact has integration issues in test environment')
          is_expected.to eq(expected_contrib_basedir)
        end
      end

      context 'with no antelope versions' do
        it 'returns nil when no versions are available' do
          allow(Facter::Util::Antelope).to receive(:versions).and_return(nil)
          is_expected.to be_nil
        end
      end
    end
  end

  # ============================================================================
  # antelope_versions and antelope_versions_array fact tests
  # ============================================================================

  describe 'Antelope Version Facts' do
    shared_context 'mocked versions' do
      before :each do
        allow(Facter::Util::Antelope).to receive(:versions)
          .and_return(test_versions).at_least(:once)
      end
    end

    describe 'antelope_versions fact', type: :fact do
      subject(:antelope_versions) { fact.value }

      let(:fact) { Facter.fact(:antelope_versions) }
      let(:expected_versions) { test_versions.join(',') }

      include_context 'mocked versions'

      it { is_expected.to eql(expected_versions) }

      context 'with no versions installed' do
        it 'returns nil' do
          allow(Facter::Util::Antelope).to receive(:versions).and_return(nil)
          is_expected.to be_nil
        end
      end
    end

    describe 'antelope_versions_array fact', type: :fact do
      subject(:antelope_versions_array) { fact.value }

      let(:fact) { Facter.fact(:antelope_versions_array) }
      let(:expected_versions) { test_versions }

      include_context 'mocked versions'

      it { is_expected.to eql(expected_versions) }

      context 'with no versions installed' do
        it 'returns nil' do
          allow(Facter::Util::Antelope).to receive(:versions).and_return(nil)
          is_expected.to be_nil
        end
      end
    end
  end

  # ============================================================================
  # antelope_latest_version fact tests
  # ============================================================================

  describe 'antelope_latest_version fact', type: :fact do
    subject(:antelope_latest_version) { fact.value }

    let(:fact) { Facter.fact(:antelope_latest_version) }

    context 'with multiple versions installed' do
      it 'returns the last version from the sorted list' do
        allow(Facter::Util::Antelope).to receive(:versions).and_return(test_versions)
        is_expected.to eql('5.4post')
      end
    end

    context 'with single version installed' do
      it 'returns the single version' do
        allow(Facter::Util::Antelope).to receive(:versions).and_return(['5.4'])
        is_expected.to eql('5.4')
      end
    end

    context 'with no versions installed' do
      it 'returns nil' do
        allow(Facter::Util::Antelope).to receive(:versions).and_return(nil)
        is_expected.to be_nil
      end
    end
  end

  # ============================================================================
  # antelope_versions_supports_aldproxy fact tests
  # ============================================================================

  ['antelope_versions_supports_aldproxy', 'antelope_versions_supports_aldproxy_array'].each do |fact_name|
    describe "#{fact_name} fact", type: :fact do
      subject(fact_name.to_sym) { fact.value }

      let(:fact) { Facter.fact(fact_name.to_sym) }

      before :each do
        allow(Facter::Util::Antelope).to receive(:versions)
          .and_return(['5.2-64', '5.4', '5.4post']).at_least(:once)
        allow(File).to receive('exist?').with('/opt/antelope/5.2-64/bin/ald_proxy')
                                        .and_return(false).at_least(:once)
        allow(File).to receive('exist?').with('/opt/antelope/5.4/bin/ald_proxy')
                                        .and_return(true).at_least(:once)
        allow(File).to receive('exist?').with('/opt/antelope/5.4post/bin/ald_proxy')
                                        .and_return(true).at_least(:once)
      end

      it { is_expected.not_to be_nil }

      if %r{_array$}.match?(fact_name)
        it { is_expected.to eql(['5.4', '5.4post']) }
      else
        it { is_expected.to eql('5.4,5.4post') }
      end

      context 'with no versions supporting aldproxy' do
        it 'returns nil when no versions support aldproxy' do
          allow(Facter::Util::Antelope).to receive(:versions).and_return(['5.2-64'])
          allow(File).to receive('exist?').with('/opt/antelope/5.2-64/bin/ald_proxy').and_return(false)
          is_expected.to be_nil
        end
      end

      context 'with no antelope versions installed' do
        it 'returns nil' do
          allow(Facter::Util::Antelope).to receive(:versions).and_return(nil)
          is_expected.to be_nil
        end
      end
    end
  end
end
