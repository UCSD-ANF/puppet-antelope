# frozen_string_literal: true

require 'spec_helper'

describe 'antelope::service_fact' do
  let(:params) do
    {
      facts_dir: '/etc/facter/facts.d',
    }
  end
  let(:pre_condition) do
    [
      'file { "/etc/facter/facts.d": ensure => "directory" }',
    ]
  end

  shared_context 'Supported Platform' do
    context 'with default parameters' do
      it { is_expected.to compile }

      it {
        is_expected.to contain_concat('/etc/facter/facts.d/antelope_services').with(
          require: 'File[/etc/facter/facts.d]',
          mode: '0755',
        )
      }

      it {
        is_expected.to contain_concat__fragment('/etc/facter/facts.d/antelope_services_header').with(
          target: '/etc/facter/facts.d/antelope_services',
          order: '00',
        ).with_content(%r{#!/usr/bin/perl})
      }

      it {
        is_expected.to contain_concat__fragment('/etc/facter/facts.d/antelope_services_header')
          .with_content(%r{my @instances = <DATA>;})
      }

      it {
        is_expected.to contain_concat__fragment('/etc/facter/facts.d/antelope_services_header')
          .with_content(%r{chomp @instances;})
      }

      it {
        is_expected.to contain_concat__fragment('/etc/facter/facts.d/antelope_services_header')
          .with_content(%r{my \$instancestr = join\(",", @instances\);})
      }

      it {
        is_expected.to contain_concat__fragment('/etc/facter/facts.d/antelope_services_header')
          .with_content(%r{print "antelope_services=\$instancestr\\n";})
      }

      it {
        is_expected.to contain_concat__fragment('/etc/facter/facts.d/antelope_services_header')
          .with_content(%r{__DATA__})
      }
    end

    context 'with custom facts_dir' do
      let(:params) do
        {
          facts_dir: '/custom/facts/dir',
        }
      end
      let(:pre_condition) do
        [
          'file { "/custom/facts/dir": ensure => "directory" }',
        ]
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_concat('/custom/facts/dir/antelope_services').with(
          require: 'File[/custom/facts/dir]',
          mode: '0755',
        )
      }

      it {
        is_expected.to contain_concat__fragment('/custom/facts/dir/antelope_services_header').with(
          target: '/custom/facts/dir/antelope_services',
          order: '00',
        )
      }
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it_behaves_like 'Supported Platform'
    end
  end
end
