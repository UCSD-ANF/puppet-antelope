# frozen_string_literal: true

# Facts: antelope_latest_perl, antelope_latest_python, antelope_latest_version
#
# The path to the highest version of Perl and Python as distributed by BRTT
#
require 'facter/util/antelope'

# Modern Facter 4+ structured facts
Facter.add(:antelope_latest_version, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    versions = Facter::Util::Antelope.versions
    version = nil
    version = versions.last unless versions.nil?
    version
  end
end

Facter.add(:antelope_latest_perl, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    latest_antelope = Facter.value(:antelope_latest_version)
    res = nil
    res = Facter::Util::Antelope.getid(latest_antelope, :perl) if latest_antelope
    res
  end
end

Facter.add(:antelope_latest_python, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    latest_antelope = Facter.value(:antelope_latest_version)
    res = nil
    res = Facter::Util::Antelope.getid(latest_antelope, :python) if latest_antelope
    res
  end
end
