# This is an example of how to use this module
# in your nodefinitions

class site::antelope {

  user { 'rt' : }

  class { 'antelope':
    rtsystems    => {
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
  }

}

node default {
  class { 'site::antelope' : }
}

# EOF
