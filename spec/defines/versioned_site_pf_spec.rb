require 'spec_helper'

describe 'antelope::versioned_site_pf' do
  let(:title) { '5.3pre' }
  context 'on a supported platform' do
    let(:facts) { {
      :osfamily => 'RedHat',
    } }

    it { should contain_file('/opt/antelope/5.3pre/data/pf/site.pf') }

    context 'with params owner and group = pkgbuild' do
      let(:params) { {
        :owner => 'pkgbuild',
        :group => 'pkgbuild',
      } }

      it { should contain_file('/opt/antelope/5.3pre/data/pf/site.pf')\
        .with_owner('pkgbuild').with_group('pkgbuild') }
    end

    context 'with global variables' do
      let(:pre_condition) { [
        "$antelope_dist_owner = 'guser'",
        "$antelope_dist_group = 'ggroup'",
      ] }

      it { should contain_file('/opt/antelope/5.3pre/data/pf/site.pf')\
        .with_owner('guser').with_group('ggroup') }
    end

    context 'with both source and content parameters' do
      let(:params) { {
        :source => '/this/should/fail',
        :content => 'This garbage content should fail',
      } }

      it {
        expect { should raise_error(Puppet::Error) }
      }
    end

    context 'with basic params' do
      let(:params) { {
        :mailhost                 => 'smtp.example.com',
        :mail_domain              => 'domain.example.com',
        :default_seed_network     => 'EX',
        :originating_organization => 'Example.com Inc.',
        :institution              => 'EXPL',
      } }

      it { should contain_file('/opt/antelope/5.3pre/data/pf/site.pf')\
        .with_content(/mailhost smtp\.example\.com/)\
        .with_content(/mail_domain domain\.example\.com/)\
        .with_content(/default_seed_network   EX/)\
        .with_content(/originating_organization Example\.com Inc\./)\
        .with_content(/Institution EXPL/)
      }

    end
  end
end
