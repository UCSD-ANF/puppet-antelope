# Fact: antelope_versions
#
# The installed versions of BRTT Antelope on a system. It is determined
# by looking at /opt/antelope for # directories matching the Antelope
# version naming convention, and then # checks to see if setup.sh is
# present in the directory.
#

# Antelope always lives under this directory
basedir = '/opt/antelope'

if File.directory?(basedir) || File.symlink?(basedir)

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

end
