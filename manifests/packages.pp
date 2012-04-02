# Packages that our Antelope stack depends on
class antelope::packages {
  # mailx provides nail
  package { 'mailx': ensure => present }

  include 'git'
  include 'imagemagick'
}
