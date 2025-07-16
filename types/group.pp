# @summary A type alias for group names or GIDs
#
# This type accepts either a group name as a string or a numeric group ID (GID)
# in the range 0-65535. Used throughout the Antelope module for specifying
# which group should own files and run processes.
#
# @example Group name as string
#   'rt'
#
# @example Numeric GID
#   1000
#
type Antelope::Group = Variant[String, Integer[0, 65535]]
