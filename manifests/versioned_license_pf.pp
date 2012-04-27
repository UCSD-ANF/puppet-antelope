#
# === Class antelope::versioned_license_pf
# Define a license.pf parameter file for a particular version of
# Antelope.
#
# This is a define rather than a class because we need to be able to
# support more than one version of Antelope being installed on a
# particular system for testing.
#
# === Parameters
#
# Parameters affecting behavior of this define:
#
# *[version]*
#  The version of Antelope that this license.pf instance will belong to
#  Defaults to $title. This is the namevar.
#
# *[source]*
#  If set, this file is copied directly with no template evaluation
#  performed. 'template' and 'source' cannot both be set. Defaults to
#  undef.
#
# *[content]*
#  If set, this is used as the file's contents. This allows you to
#  specify your own template in case the default template doesn't work
#  for you. Defaults to template('puppet/license.pf.erb'). It is an
#  error to define both template and source at the same time.
#
# *[replace]*
#  If true or yes, the contents of the file will be replaced if it
#  exists. If false or no (the default) any existing contents are left
#  in place
#
# Parameters affecting template evaluation:
#
# *[license_keys]*
#  An array containing license keys, one per array element.
#
# *[expiration_warnings]*
#  If false, the parameter 'no_more_expiration_warnings' is set in
#  license.pf. If true, it's not set
#
# === Example
#
#    # Set the license.pf for the latest version of Antelope:
#    antelope::versioned_license_pf( $::antelope_latest_version :
#      keys    => [
#        'tabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo.ucsd.edu Antelope 5.1',
#        'tabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo.ucsd.edu Antelope 5.1',
#      ],
#      replace => true,
#    }
#
define antelope::versioned_license_pf (
  $version             = $title,
  $source              = undef,
  $content             = undef,
  $license_keys        = undef,
  $replace             = false,
  $expiration_warnings = true
) {

  $filename="/opt/antelope/${version}/data/pf/license.pf"

  if $content != '' and $source != '' {
    fail('Cannot specify both content and source')
  }

  $file_source = $source ? {
    ''      => undef, # default value
    default => $source,
  }

  $file_content = $source ? {
    '' => $content ? {
      ''      => template('antelope/license.pf.erb'), # default value
      default => $content,
    },
  }

  $file_replace = $replace

  ### Managed resources

  file { $filename :
    ensure  => $file_ensure,
    source  => $file_source,
    content => $file_content,
    replace => $file_replace,
  }

}
