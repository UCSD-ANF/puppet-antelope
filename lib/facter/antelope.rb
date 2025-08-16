# frozen_string_literal: true

# Antelope Real-Time System Facts
#
# This file consolidates all Antelope-related facts to ensure they load properly.
# Facts included:
# - antelope_versions / antelope_versions_array
# - antelope_latest_version
# - antelope_latest_perl
# - antelope_latest_python
# - antelope_contrib_basedir
# - antelope_versions_supports_aldproxy / antelope_versions_supports_aldproxy_array

require 'facter/util/antelope'

# Dummy module definition for namespacing (kept for compatibility)
module Facter::Antelope
end

# ============================================================================
# Antelope Versions Facts
# ============================================================================

# Get all available versions
versions = Facter::Util::Antelope.versions

# Main antelope_versions fact (comma-separated string)
Facter.add(:antelope_versions) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode { versions.join(',') } unless versions.nil?
end

# Array version of antelope_versions
Facter.add(:antelope_versions_array) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode { versions } unless versions.nil?
end

# ============================================================================
# Latest Version Facts
# ============================================================================

# Latest Antelope version
Facter.add(:antelope_latest_version) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    version = nil
    version = versions.last unless versions.nil?
    version
  end
end

# Latest Perl version for Antelope
Facter.add(:antelope_latest_perl) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    latest_antelope = Facter.value(:antelope_latest_version)
    res = nil
    res = Facter::Util::Antelope.getid(latest_antelope, :perl) if latest_antelope
    res
  end
end

# Latest Python version for Antelope
Facter.add(:antelope_latest_python) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    latest_antelope = Facter.value(:antelope_latest_version)
    res = nil
    res = Facter::Util::Antelope.getid(latest_antelope, :python) if latest_antelope
    res
  end
end

# ============================================================================
# Contrib Directory Facts
# ============================================================================

# Antelope contrib base directory
Facter.add(:antelope_contrib_basedir) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    antelope_versions = Facter::Util::Antelope.versions
    unless antelope_versions.nil?
      result = antelope_versions.map { |version|
        contrib_exists = File.directory?("/opt/antelope/#{version}/contrib/bin")
        [version, contrib_exists ? '/contrib' : '']
      }.to_h
      result
    end
  end
end

# ============================================================================
# ALD Proxy Support Facts
# ============================================================================

# Antelope versions that support aldproxy (comma-separated string)
Facter.add(:antelope_versions_supports_aldproxy) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    if versions.nil?
      nil
    else
      aldproxy_versions = versions.select do |version|
        File.exist?("/opt/antelope/#{version}/bin/ald_proxy")
      end
      aldproxy_versions.empty? ? nil : aldproxy_versions.join(',')
    end
  end
end

# Array version of aldproxy support
Facter.add(:antelope_versions_supports_aldproxy_array) do
  confine kernel: Facter::Util::Antelope::VALID_KERNELS
  setcode do
    if versions.nil?
      nil
    else
      aldproxy_versions = versions.select do |version|
        File.exist?("/opt/antelope/#{version}/bin/ald_proxy")
      end
      aldproxy_versions.empty? ? nil : aldproxy_versions
    end
  end
end
