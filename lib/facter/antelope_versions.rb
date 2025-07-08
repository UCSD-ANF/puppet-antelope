# frozen_string_literal: true

# Fact: antelope_versions

require 'facter/util/antelope'

# Modern Facter 4+ structured facts
Facter.add(:antelope_versions, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    versions = Facter::Util::Antelope.versions
    versions&.join(',')
  end
end

Facter.add(:antelope_versions_array, type: :simple) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    Facter::Util::Antelope.versions
  end
end
