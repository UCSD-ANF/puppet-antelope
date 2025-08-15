#
# === Class antelope::versioned_site_pf
# Define a site.pf parameter file for a particular version of Antelope.
#
# This is a define rather than a class because we need to be able to
# support more than one version of Antelope being installed on a
# particular system for testing.
#
# === Parameters
#
# Parameters affecting antelope::versioned_site_pf's behavior:
# *[ensure]*
#  Either present or absent. If absent, file is removed. Default: present
#
# *[version]*
#  The version of Antelope that this site.pf instance will belong to.
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
#  for you. Defaults to template('puppet/site.pf.erb'). It is an error
#  to define both template and source at the same time.
#
# *[path]*
#  If set, override the default filename. Defaults to
#  '/opt/antelope/$version/data/pf/site.pf'
#
# Parameters affecting template evaluation:
#
# *[mailhost]*
#  Used by site.pf template evaluation. Accessible IP address or
#  hostname of system running mail relay agent. Defaults to ''
#
# *[mail_domain]*
#  Used by site.pf template evaluation. Domain name for outgoing mail
#  -- e.g., 'brtt.com'. Defaults to $::fqdn
#
# *[default_seed_network]*
#  Used by site.pf template evaluation. Used in miniseed headers. This
#  code is officially assigned so don't pick one arbitrarily. Put that
#  code in here, or use the default 'XX' code.
#
# *[originating_organization]*
#  Used by site.pf template evaluation. Used in SEED volumes in the
#  '010 blockette'. Fill in the long name of your organization or
#  institution here. Default is ''.
#
# *[institution]*
#  Maps to the big-'I' 'Institution' parameter in site.pf. Short code
#  part of the author field in the origin table, e.g., UCSD.
#  The combination of this short code and the username in the Antelope
#  origin table can only be 14 characters after one is burned for a
#  colon delimiter, e.g. $INSTITUTION:$USER. Default is 'XXXX'.
#
# === Example
#
#    # Set the site.pf for the latest version of Antelope:
#    antelope::versioned_site_pf( $::antelope_latest_version :
#      mail_relay               => 'smtp.ucsd.edu',
#      mail_domain              => 'ucsd.edu',
#      default_seed_network     => 'TA',
#      originating_organization => 'UC San Diego',
#      institution              => 'UCSD',
#    }
#
# @param ensure Whether the site.pf file should be present or absent. Defaults to 'present'.
# @param mailhost The SMTP mail server hostname for Antelope email notifications. Used in template generation.
# @param mail_domain The email domain for Antelope email notifications. Used in template generation.
# @param default_seed_network The default seismic network code for seed data. Used in template generation.
# @param originating_organization The organization name for data attribution. Used in template generation.
# @param institution The institution name for system identification. Used in template generation.
# @param version The Antelope version for this site configuration. Defaults to the resource name.
# @param source The source location for the site.pf file (puppet:// URI). Mutually exclusive with content parameter.
# @param content The literal content for the site.pf file. Mutually exclusive with source parameter.
# @param owner The file owner for the site.pf file. Defaults to lookup value.
# @param group The file group for the site.pf file. Defaults to lookup value.
# @param mode The file permissions for the site.pf file. Defaults to lookup value.
# @param path The full path where the site.pf file should be created. If not specified, will be auto-generated based on version.
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
  include 'antelope'

  # Use lookup() inside the define body to get defaults from Hiera
  $owner_real = pick($owner, lookup('antelope::dist_owner'))
  $group_real = pick($group, lookup('antelope::dist_group'))
  $mode_real = pick($mode, lookup('antelope::site_pf_mode'))

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

  $file_owner = $owner_real

  $file_group = $group_real

  $file_mode = $mode_real

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
