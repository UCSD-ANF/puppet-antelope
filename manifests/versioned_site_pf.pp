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
define antelope::versioned_site_pf (
  Enum['present', 'absent']       $ensure,
  String                          $mailhost = '',
  Stdlib::Fqdn                    $mail_domain = $::facts['fqdn'],
  String                          $default_seed_network = 'XX',
  String                          $originating_organization = '',
  String                          $institution = 'XXXX',
  Antelope::Version               $version = $title,
  Optional[String]                $source,
  Optional[String]                $content,
  Antelope::User                  $owner = lookup('antelope::dist_owner'),
  Antelope::Group                 $group = lookup('antleope::dist_group'),
  String                          $mode  = lookup('antleope::dist_mode'),
  Optional[Stdlib::Absolutepath]  $path
) {
  include '::antelope'

  $file_ensure = $ensure

  $file_path   = pick($path, "/opt/antelope/${version}/data/pf/site.pf")

  if $content != undef and $source != undef {
    fail('Cannot specify both content and source')
  }

  $file_source = $source

  if $file_source {
    $file_content = pick($content, template('antelope/site.pf.erb'))
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
