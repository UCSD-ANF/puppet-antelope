# @summary Creates a site.pf parameter file for a specific Antelope version
#
# This defined type creates a site.pf parameter file for a particular version
# of Antelope. Multiple instances can be created for different versions to
# support testing scenarios.
#
# @param ensure
#   Whether the site.pf file should be present or absent
# @param mailhost
#   Hostname or IP address of mail relay agent
# @param mail_domain
#   Domain name for outgoing mail (defaults to FQDN)
# @param default_seed_network
#   Network code used in miniseed headers (officially assigned)
# @param originating_organization
#   Organization name for SEED volumes
# @param institution
#   Short institution code for origin table author field
# @param version
#   Antelope version (defaults to title)
# @param source
#   Source file to copy (mutually exclusive with content)
# @param content
#   File content (mutually exclusive with source)
# @param owner
#   File owner
# @param group
#   File group
# @param mode
#   File mode
# @param path
#   Override default file path
#
# @example Create site.pf for latest Antelope version
#   antelope::versioned_site_pf { $facts['antelope_latest_version']:
#     mailhost                 => 'smtp.example.com',
#     mail_domain              => 'example.com',
#     default_seed_network     => 'TA',
#     originating_organization => 'Example University',
#     institution              => 'EXMP',
#   }
#
define antelope::versioned_site_pf (
  Enum['present', 'absent']       $ensure                   = 'present',
  String                          $mailhost                 = '',
  Stdlib::Fqdn                    $mail_domain              = $::facts['fqdn'],
  String                          $default_seed_network     = 'XX',
  String                          $originating_organization = '',
  String                          $institution              = 'XXXX',
  Antelope::Version               $version                  = $title,
  Optional[String]                $source                   = undef,
  Optional[String]                $content                  = undef,
  Antelope::User                  $owner                    = lookup('antelope::dist_owner'),
  Antelope::Group                 $group                    = lookup('antelope::dist_group'),
  String                          $mode                     = lookup('antelope::dist_mode'),
  Optional[Stdlib::Absolutepath]  $path                     = undef
) {
  include '::antelope'

  $file_ensure = $ensure

  $file_path   = pick($path, "/opt/antelope/${version}/data/pf/site.pf")

  if $content != undef and $source != undef {
    fail('Cannot specify both content and source')
  }

  $file_source = $source

  $file_content = $file_source ? {
    undef => $content ? {
      undef => template('antelope/site.pf.erb'),
      default => $content,
    },
    default => undef,
  }

  $file_owner = $owner

  $file_group = $group

  $file_mode = $mode

  file { "antelope site.pf ${title}" :
    ensure  => $file_ensure,
    path    => $file_path,
    source  => $file_source,
    content => $file_content,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
  }
}
