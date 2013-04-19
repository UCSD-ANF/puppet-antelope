require 'spec_helper'

describe 'antelope' do
  context 'on a supported osfamily' do
    let (:facts) { {
      :osfamily => 'RedHat',
    } }

    let (:pre_condition) { [
      "$concat_basedir='/tmp'",
      "user { 'rt': }",
    ] }

    context 'with no dirs or instances' do
      it { should_not contain_antelope__instance('antelope') }
    end

    context 'with a single dir' do
      let (:params) { {
        :dirs => '/export/home/rt/rtsystems/test'
      } }
      it { should contain_antelope__instance('antelope') }
    end

    context 'with instances hash' do
      let (:params) { {
        :instances => {
        'antelope-single' => {
          'user'   => 'rt',
         'dirs'   => '/export/home/rt/rtsystems/single',
        },
        'antelope-csv' => {
          'user'       => 'rt',
          'dirs'       => '/export/home/rt/rtsystems/csv1,/export/home/rt/rtsystems/csv2',
        },
        'antelope-arr' => {
          'user'       => 'rt',
          'dirs'       => [
            '/export/home/rt/rtsystems/arr1',
            '/export/home/rt/rtsystems/arr2',
          ],
        },
      },
      } }

      it do
        should contain_antelope__instance('antelope-single')
        should contain_antelope__instance('antelope-csv')
        should contain_antelope__instance('antelope-arr')
      end

    end
  end
end
