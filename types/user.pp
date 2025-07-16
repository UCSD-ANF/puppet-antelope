# @summary A type alias for user names or UIDs
#
# This type accepts either a username as a string or a numeric user ID (UID)
# in the range 0-65535. Used throughout the Antelope module for specifying
# which user should own files and run processes.
#
# @example Username as string
#   'rt'
#
# @example Numeric UID
#   1000
#
type Antelope::User = Variant[String, Integer[0, 65535]]
