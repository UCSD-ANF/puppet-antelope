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
