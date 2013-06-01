# Fact: antelope_latest_version
#
# The antelope_latest_version is the highest version of Antelope
# installed on the system. Typically is also the most-recent release
#
Facter.add(:antelope_latest_version) do
  confine :kernel => %w{Linux SunOS Darwin}
  setcode do
    version=nil

    versionstr = Facter.value('antelope_versions')
    versions = Facter::Util::Antelope.get_versions
    version = versions.last unless versions.nil?

    version
  end
end
