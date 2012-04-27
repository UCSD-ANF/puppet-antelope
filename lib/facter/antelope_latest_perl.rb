# Fact: antelope_latest_perl
#
# The path to the highest version of Perl as distributed by BRTT
#

# Antelope always lives under this directory
basedir = '/opt/antelope'

if File.directory?(basedir) || File.symlink?(basedir)
  Facter.add(:antelope_latest_perl) do

    confine :kernel => %w{Linux SunOS Darwin}

    setcode do
      result = nil
      dirs=Dir.entries(basedir).sort

      dirs.each do |dir|
        dir=dir.chomp
        next unless dir =~/^perl\d+\.\d+(.\d+)?(-64)?$/
        next unless File.exists?(File.join(basedir, dir, 'bin/perl'))
        result = dir
      end

      result
    end
  end
end