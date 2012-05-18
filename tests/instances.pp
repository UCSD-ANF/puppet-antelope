# This is an example of how to use this module
# in your nodefinitions

class site::antelope {

  user { 'rt' : }

  file{'/etc/facter': ensure => present, }
  -> file{'/etc/facter/facts.d': ensure => present, }

  class { '::antelope':
    dirs => '/export/home/rt/rtsystems/foo',
  }

}

node default {
  class { 'site::antelope' : }
}

# EOF
