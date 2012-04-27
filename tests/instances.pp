# This is an example of how to use this module
# in your nodefinitions

class site::antelope {

  user { 'rt' : }

  class { '::antelope':
    dirs => '/export/home/rt/rtsystems/foo',
  }

}

node default {
  class { 'site::antelope' : }
}

# EOF
