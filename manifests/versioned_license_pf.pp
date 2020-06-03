#
# === Defined type antelope::versioned_license_pf
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
# *[ensure]*
#  Either present or absent. If absent, file is removed. Default: present
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
# *[path]*
#  If set, this is used as the filename for the license file. This allows you
#  specify an arbitrary location for license files for staging purposes.
#  Defaults to '/opt/antelope/$version/data/pf/license.pf'
#
# Parameters affecting template evaluation:
#
# *[license_keys]*
#  An array containing license keys, one per array element.
#
# *[expiration_warnings]*
#  If false, the parameter 'no_more_expiration_warnings' is set in
#  license.pf. If true, it's not set in license.pf
#
# === Example
#
#    # Set the license.pf for the latest version of Antelope:
#    antelope::versioned_license_pf( $::antelope_latest_version :
#      license_keys    => [
#        'tabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo',
#        'tbbadef1234567890abcdef1234567890abcdef12 2014 May 01 # node bar',
#      ],
#      replace => true,
#    }
#
define antelope::versioned_license_pf (
  Enum['present', 'absent']       $ensure              = 'present',
  Antelope::Version               $version             = $title,
  Optional[String]                $source              = undef,
  Optional[String]                $content             = undef,
  Optional[String]                $license_keys        = undef,
  Boolean                         $replace             = false,
  Boolean                         $expiration_warnings = true,
  Optional[Antelope::User]        $owner               = undef,
  Optional[Antelope::Group]       $group               = undef,
  Optional[String]                $mode                = undef,
  Optional[Stdlib::Absolutepath]  $path                = undef,
) {
  include '::antelope'

  $file_ensure = $ensure
  $file_path = $path ? {
    undef   => "/opt/antelope/${version}/data/pf/license.pf",
    default => $path,
  }

  if $content != undef and $source != undef {
    fail('Cannot specify both content and source')
  }

  $file_source = $source ? {
    undef   => undef, # default value
    default => $source,
  }

  $file_content = $source ? {
    undef => $content ? {
      undef   => template('antelope/license.pf.erb'), # default value
      default => $content,
    },
    default => undef,
  }

  $file_replace = $replace

  $file_owner = $owner ? {
    undef   => $antelope::dist_owner,
    default => $owner,
  }

  $file_group = $group ? {
    undef   => $antelope::dist_group,
    default => $group,
  }

  $file_mode = $mode ? {
    undef   => $antelope::dist_mode,
    default => $mode,
  }

  ### Managed resources

  file { "antelope license.pf ${title}" :
    ensure  => $file_ensure,
    path    => $file_path,
    source  => $file_source,
    content => $file_content,
    replace => $file_replace,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
  }

}
