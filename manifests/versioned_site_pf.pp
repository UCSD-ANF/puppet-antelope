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
  Optional[String]                $mailhost                 = undef,
  Stdlib::Fqdn                    $mail_domain              = $facts['networking']['fqdn'],
  String                          $default_seed_network     = 'XX',
  Optional[String]                $originating_organization = undef,
  String                          $institution              = 'XXXX',
  Antelope::Version               $version                  = $title,
  Optional[String]                $source                   = undef,
  Optional[String]                $content                  = undef,
  Optional[Antelope::User]        $owner                    = undef,
  Optional[Antelope::Group]       $group                    = undef,
  Optional[String]                $mode                     = undef,
  Optional[Stdlib::Absolutepath]  $path                     = undef
) {
  include antelope

  # Set parameter defaults from antelope class
  $_owner = $owner ? {
    undef   => $antelope::dist_owner,
    default => $owner,
  }
  $_group = $group ? {
    undef   => $antelope::dist_group,
    default => $group,
  }
  $_mode = $mode ? {
    undef   => $antelope::dist_mode,
    default => $mode,
  }

  $file_ensure = $ensure

  $file_path   = pick($path, "/opt/antelope/${version}/data/pf/site.pf")

  if $content != undef and $source != undef {
    fail('Cannot specify both content and source')
  }

  $file_source = $source

  $file_content = $file_source ? {
    undef => $content ? {
      undef => epp('antelope/site.pf.epp', {
          'mailhost'                 => $mailhost ? { undef => '', default => $mailhost },
          'mail_domain'              => $mail_domain,
          'default_seed_network'     => $default_seed_network,
          'originating_organization' => $originating_organization ? { undef => '', default => $originating_organization },
          'institution'              => $institution,
      }),
      default => $content,
    },
    default => undef,
  }

  $file_owner = $_owner

  $file_group = $_group

  $file_mode = $_mode

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
