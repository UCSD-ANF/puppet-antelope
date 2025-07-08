# @summary Enable Antelope PHP extensions
#
# This class enables Antelope PHP extensions that have been built from
# the Antelope Contributed software repository.
#
# @param version
#   Antelope version to use for PHP extensions
# @param ensure
#   Whether the PHP extensions should be present or absent
#
# @example Enable Antelope PHP extensions
#   include antelope::php
#
class antelope::php (
  Antelope::Version         $version,
  Enum['present', 'absent'] $ensure
) {
  php::config { 'antelope':
    ensure  => $ensure,
    content => template('antelope/php.erb'),
  }
}
