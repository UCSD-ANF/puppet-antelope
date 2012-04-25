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
