# Fact: antelope_versions
# Fact: latest_antelope_version
#
# These two facts represent the installed versions of BRTT Antelope on
# a system. It determines this by looking at /opt/antelope for
# directories matching the Antelope version naming convention, and then
# checks to see if setup.sh is present in the directory.
#
# The lastest_antelope_version is the most recent version of Antelope
# installed on the system.

# Antelope always lives under this directory
basedir = '/opt/antelope'

Facter.add(:antelope_versions) do
  confine :kernel => %w{Linux SunOS Darwin}
  setcode do
    versions = Array.new
    dirs=Dir.entries(basedir).sort

    dirs.each do |dir|
      dir=dir.chomp
      next unless dir =~ /^\d+\.\d+(-64)?p?/
      next unless File.exists?(File.join(basedir, dir, 'setup.sh'))
      versions.insert(-1,dir)
    end

    versions.join(',')
  end
end

Facter.add(:latest_antelope_version) do
  confine :kernel => %w{Linux SunOS Darwin}
  setcode do
    version=nil
    versionstr = Facter.value('antelope_versions')
    version = versionstr.split(',').last unless versionstr == nil

    version
  end
end
