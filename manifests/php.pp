# Enable Antelope PHP extensions
#
# Requirements:
#  * This requires that you have build the Antelope PHP extensions from
#  the Antelope Contributed software repository.
#  * The puppet-php module with support for the php::config class.
#  See https://github.com/UCSD-ANF/puppet-php
# @param version The Antelope version for which to enable PHP extensions. Must match an installed Antelope version.
# @param ensure Whether the PHP integration should be present or absent. Defaults to 'present'.
class antelope::php (
  Antelope::Version         $version,
  Enum['present', 'absent'] $ensure
) {
  php::config { 'antelope':
    ensure  => $ensure,
    content => template('antelope/php.erb'),
  }
}
