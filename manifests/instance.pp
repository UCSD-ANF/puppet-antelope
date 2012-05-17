# instance.pp

# Install an Antelope init script for a list of real-time systems
#
# == Parameters
#
# [*servicename*]
#   The name of the init resource name, after /etc/init.d. Typically set to
# "antelope". Defaults to the value of title - this is the namevar
#
# [*dirs*]
#   List of directories containing real-time systems.
# e.g. "/export/home/rt/dirs/usarray"
#
# [*user*]
#   The username that the Antelope real-time systems should run as. Defaults
#  to 'rt'.
#
# [*delay*]
#   Number of seconds to delay between startups. Default value of 0 means no
# delay.
#
# [*ensure*]
#   Controls whether the service should be there or not
#
# [*shutdownwait*]
#   How long to wait in seconds for a real-time system to shutdown. Defaults
#   to 120 seconds.
#
# [*manage_fact*]
#   If false, does not manage the facter fact antelope_instances.
#   Defaults to true
#
# == Autorequires
# This resource auto-requires the following resources:
#  User[$user]
#
# == Examples
#
# Two real-time systems running under user rt
#    antelope::instance{
#      'antelope':
#        dirs => [ '/export/home/rt/dirs/usarray',
#                      '/export/home/rt/dirs/roadnet', ],
#    }
#
# A single real-time system running under user rtida
#    antelope::instance{
#      'antelope-rtida':
#        dirs  => '/export/home/rtida/dirs/ida',
#        user       => 'rt',
#    }
#
define antelope::instance (
  $ensure       = 'present',
  $dirs         = undef,
  $user         = 'rt',
  $servicename  = $title,
  $delay        = '0',
  $shutdownwait = '120',
  $manage_fact  = false
) {

  require 'antelope::params'
  # Sanity test parameters
  validate_string($ensure)
  validate_string($user)
  validate_string($servicename)
  validate_string($delay)
  validate_bool($manage_fact)

  if $manage_fact {
    include 'antelope::instance_fact'
  }

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail('antelope::instance ensure parameter must be absent or present')
  }

  if ( $ensure == 'present' ) and ( $dirs == undef ) {
    fail('antelope::instance - service enabled but no dirs specified')
  }



  # Verify we have an integer value for $delay
  if ( $ensure == 'present' ) {
    if ! ( is_integer($delay)) {
      fail("antelope::instance - delay parameter must be an integer")
    }
  }

  # Set local variables based on the desired state
  # In our management model, we don't ensure the service is running
  if $ensure == 'present' {
    $file_ensure = 'file'
    $service_enable = true
  } else {
    $file_ensure = 'absent'
    $service_enable = false
  }

  # Determine the path to the init script on Solaris and RedHat/CentOS
  $initfilename = "/etc/init.d/${servicename}"

  # declare relations based on desired behavior
  if $ensure == 'present' {
    File[$initfilename]  ~> Service[$servicename]
    User[$user]          -> Service[$servicename]
  } else {
    Service[$servicename] -> File[$initfilename]
  }

  # array of directories that gets evaluated by the template
  $real_dirs = is_array($dirs) ? {
    true  => $dirs,
    false => split($dirs, ','),
  }

  ### Managed resources

  # Declare our resources without relationships
  # init script path for Solaris and Linux
  file { $initfilename :
    ensure  => $file_ensure,
    mode    => '0755',
    content => template('antelope/S99antelope.erb'),
  }

  # On solaris we don't use SMF. We provide a bare init script which requires
  # manual creation of symlinks
  case $::operatingsystem {
   'Solaris':           {
     Service { provider => 'init' }
     if $service_enable == true {
       # Create symlinks
       file {
         "/etc/rc0.d/K01$servicename":
           ensure => link,
           target => $initfilename;
         "/etc/rc1.d/K01$servicename":
           ensure => link,
           target => $initfilename;
         "/etc/rc3.d/S99$servicename":
           ensure => link,
           target => $initfilename;
       }
     }
     else {
       # Remove symlinks
       file {
         "/etc/rc0.d/K01$servicename": ensure => absent;
         "/etc/rc1.d/K01$servicename": ensure => absent;
         "/etc/rc3.d/S99$servicename": ensure => absent;
       }
     }
   }

   default : { }
  }

  service { $servicename:
    enable      => $service_enable,
    hasrestart  => false,
    hasstatus   => false;
  }

  if $manage_fact {
    concat::fragment { "${antelope::instance_fact::file}_${name}" :
      ensure  => $file_ensure,
      target  => $antelope::instance_fact::file,
      order   => '20',
      content => "${name}\n",
    }
  }

}
