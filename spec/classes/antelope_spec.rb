require 'spec_helper'

describe 'antelope' do
  context 'on a supported osfamily' do
    let (:facts) do {
      :osfamily => 'RedHat',
    } end
    let (:pre_condition) do [
      "$concat_basedir='/tmp'",
      "user { 'rt': }",
    ] end

    context 'with no dirs or instances' do
      it { should_not contain_antelope__instance('antelope') }
    end

    context 'with a single dir' do
      let (:params) { {
        :dirs => '/export/home/rt/rtsystems/test'
      } }
      it { should contain_antelope__instance('antelope') }
      it { should contain_file('/etc/init.d/antelope').with_content(
        /@dirs = \( "\/export\/home\/rt\/rtsystems\/test" \);/
      ) }
    end

    context 'with a multiple dirs' do
      let (:params) do {
        :dirs => [
          '/export/home/rt/rtsystems/foo',
          '/export/home/rt/rtsystems/bar',
      ] } end
      it { should contain_antelope__instance('antelope') }
      it { should contain_file('/etc/init.d/antelope').with_content(
        /@dirs = \( "\/export\/home\/rt\/rtsystems\/foo", "\/export\/home\/rt\/rtsystems\/bar" \);/
      ) }
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
      context 'with instance_subscribe array' do
        let (:params) do {
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
          :instance_subscribe => [ 'Service["foo"]' ],
        } end
        it { should contain_exec('/etc/init.d/antelope-single stop').with_notify('Service["foo"]') }
        it { should contain_exec('/etc/init.d/antelope-csv stop').with_notify('Service["foo"]') }
        it { should contain_exec('/etc/init.d/antelope-arr stop').with_notify('Service["foo"]') }
      end
    end
  end
end
