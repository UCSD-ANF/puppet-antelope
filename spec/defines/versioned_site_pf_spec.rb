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
  end
end
