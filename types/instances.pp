# @summary A type alias for Antelope instance configurations
#
# This type defines a hash structure for configuring multiple Antelope instances
# through the main antelope class. Each key is the instance name, and the value
# is a struct containing configuration parameters for that instance.
#
# @example Multiple instances
#   {
#     'antelope-primary' => {
#       user => 'rt',
#       dirs => '/rtsystems/primary',
#       delay => 5,
#     },
#     'antelope-backup' => {
#       user => 'rtbackup',
#       dirs => '/rtsystems/backup',
#       manage_fact => false,
#     },
#   }
#
type Antelope::Instances = Hash[String, Struct[{
      Optional[ensure]              => Enum['present', 'absent'],
      Optional[dirs]                => Antelope::Dirs,
      Optional[user]                => Antelope::User,
      Optional[group]               => Antelope::Group,
      Optional[delay]               => Integer,
      Optional[shutdownwait]        => Integer,
      Optional[manage_fact]         => Boolean,
      Optional[manage_rtsystemdirs] => Boolean,
      Optional[subscriptions]       => Array
}]]
