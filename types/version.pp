# @summary A type alias for Antelope version strings
#
# This type validates Antelope version strings. It accepts versions from 4.x
# through 9.x with optional suffixes like 'pre', 'post', '-64', '-64p', or 'p'.
# The module supports Antelope versions 5.9 through 5.15.
#
# @example Standard version
#   '5.15'
#
# @example Version with suffix
#   '5.2-64'
#
type Antelope::Version = Pattern[/^[4-9]\.[0-9]+(pre|post|-64|-64p|p)?$/]
