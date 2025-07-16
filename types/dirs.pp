# @summary A type alias for Antelope real-time system directory paths
#
# This type accepts either a single absolute path or an array of absolute paths
# representing directories that contain Antelope real-time systems.
#
# @example Single directory
#   '/rtsystems/usarray'
#
# @example Multiple directories
#   ['/rtsystems/usarray', '/rtsystems/ci']
#
type Antelope::Dirs = Variant[Stdlib::Absolutepath,Array[Stdlib::Absolutepath]]
