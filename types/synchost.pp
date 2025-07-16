# @summary A type alias for rsync hostnames
#
# This type validates hostnames that can be used with rsync for synchronizing
# Antelope installations. It accepts standard hostnames and optionally allows
# the 'rsync://' protocol prefix for rsync daemon connections.
#
# @example Standard hostname
#   'build.example.com'
#
# @example With rsync protocol
#   'rsync://build.example.com'
#
type Antelope::Synchost = Pattern[/\A((rsync:\/\/|)([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/]
