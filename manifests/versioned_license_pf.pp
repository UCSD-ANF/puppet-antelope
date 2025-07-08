# @summary Creates a license.pf parameter file for a specific Antelope version
#
# This defined type creates a license.pf parameter file for a particular version
# of Antelope. Multiple instances can be created for different versions to
# support testing scenarios.
#
# @param ensure
#   Whether the license.pf file should be present or absent
# @param replace
#   Whether to replace the contents if the file exists
# @param expiration_warnings
#   Whether to show expiration warnings in license.pf
# @param owner
#   File owner
# @param group
#   File group
# @param mode
#   File mode
# @param version
#   Antelope version (defaults to title)
# @param path
#   Override default file path
# @param source
#   Source file to copy (mutually exclusive with content)
# @param content
#   File content (mutually exclusive with source)
# @param license_keys
#   Array containing license keys, one per array element
#
# @example Set the license.pf for the latest version of Antelope
#   antelope::versioned_license_pf { $facts['antelope_latest_version']:
#     license_keys => [
#       'tabcdef1234567890abcdef1234567890abcdef12 2014 May 01 # node foo',
#       'tbbadef1234567890abcdef1234567890abcdef12 2014 May 01 # node bar',
#     ],
#     replace => true,
#   }
#
define antelope::versioned_license_pf (
  Enum['present', 'absent']         $ensure               = 'present',
  Boolean                           $replace              = false,
  Boolean                           $expiration_warnings  = true,
  Antelope::User                    $owner                = lookup('antelope::user'),
  Antelope::Group                   $group                = lookup('antelope::group'),
  String                            $mode                 = lookup('antelope::dist_mode'),
  Antelope::Version                 $version              = $title,
  Optional[Stdlib::Absolutepath]    $path                 = undef,
  Optional[String]                  $source               = undef,
  Optional[String]                  $content              = undef,
  Optional[Variant[String, Array]]  $license_keys         = undef,
) {
  include antelope

  $file_ensure = $ensure
  $file_path = pick($path, "/opt/antelope/${version}/data/pf/license.pf")

  if $content != undef and $source != undef {
    fail('Cannot specify both content and source')
  }

  $file_source = $source

  if !$file_source {
    $file_content = pick($content, epp('antelope/license.pf.epp', {
          'license_keys'         => $license_keys,
          'expiration_warnings'  => $expiration_warnings,
    }))
  } else {
    $file_content = undef
  }

  $file_replace = $replace
  $file_owner = $owner
  $file_group = $group
  $file_mode = $mode

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
