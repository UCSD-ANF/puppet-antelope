##
## antelope.rb
##
## a set of utility methods to interact with a BRTT Antelope installation.
##
## Copyright (C) 2013 The Regents of The University of California
## Author: Geoff Davis <gadavis@ucsd.edu>
##

module Facter::Util::Antelope
  require 'facter/util/resolution'

  VALID_KERNELS = %w{Linux SunOS Darwin}
  ANTELOPE_BASEDIR = '/opt/antelope'
  RE_VERSION = /^(\d+)\.(\d+)(-64)?(pre|post|p)?$/

  # Return a list of all Antelope versions installed on this system
  def self.get_versions
    begin
      dirs = Dir.entries(ANTELOPE_BASEDIR)
      versions = Array.new

      dirs.each do |dir|
        dir=dir.chomp
        next unless dir =~ RE_VERSION
        next unless File.exists?(File.join(ANTELOPE_BASEDIR, dir, 'setup.sh'))
        versions.insert(-1,dir)
      end

      versions.sort{|a,b| self.sort_versions(a,b)}
    rescue
      nil
    end
  end

  def self.getid(version, id)
    antelopepath="#{Facter::Util::Antelope::ANTELOPE_BASEDIR}/#{version}"
    res = %x{ ANTELOPE=#{antelopepath}; export ANTELOPE; #{antelopepath}/bin/getid #{id} 2> /dev/null}
    res.chomp!
    res
  end


  # Sort Antelope versions from oldest to newest
  # 5.2-64 < 5.2-64p < 5.3pre < 5.3 < 5.3post
  def self.sort_versions(a,b)
    amatch=RE_VERSION.match(a)
    bmatch=RE_VERSION.match(b)
    if Integer(amatch[1]) < Integer(bmatch[1])
      return -1
    elsif Integer(amatch[1]) > Integer(bmatch[1])
      return 1
    else
      # major is equal
      if Integer(amatch[2]) < Integer(bmatch[2])
        return -1
      elsif Integer(amatch[2]) > Integer(bmatch[2])
        return 1
      else
        # major and minor are equal
        # check the bits
        if amatch[3].nil? and not bmatch[3].nil?
          return 1
        elsif bmatch[3].nil? and not amatch[3].nil?
          return +1
        else
          # Major, minor, and bits are equal
          # Check the suffix for pre release versus post-release
          if amatch[4] == bmatch[4]
            #tie-break with a
            return 0
          elsif amatch[4] == 'pre'
            return -1
          elsif bmatch[4] == 'pre'
            return 1
          elsif amatch[4] == 'p' or amatch[4] == 'post'
            return 1
          else
            return -1
          end
        end
      end
    end
  end

end
