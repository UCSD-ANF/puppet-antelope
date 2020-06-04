# Enable Antelope PHP extensions
#
# Requirements:
#  * This requires that you have build the Antelope PHP extensions from
#  the Antelope Contributed software repository.
#  * The puppet-php module with support for the php::config class.
#  See https://github.com/UCSD-ANF/puppet-php
class antelope::php (
  Antelope::Version         $version,
  Enum['present', 'absent'] $ensure
){
  php::config{ 'antelope':
    ensure  => $ensure,
    content => template('antelope/php.erb'),
  }
}
