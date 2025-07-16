# frozen_string_literal: true

# MCollective Agent for BRTT Antelope
#
# This agent provides remote management capabilities for Antelope installations
# through MCollective. It defines a single action called 'sync' that can execute
# the antelope_sync script with various modes.
class MCollective::Agent::Antelope < MCollective::RPC::Agent
  activate_when do
    File.executable?('/usr/local/bin/antelope_sync')
  end

  action 'sync' do
    mode = request[:mode] || @config.pluginconf.fetch('antelope.sync_mode',
                                                      'normal')
    opts = case mode
           when 'dry-run'
             '-n'
           when 'nostopstart'
             '-S'
           when 'norestart'
             '-s'
           else
             ''
           end
    cmd = ['/usr/local/bin/antelope_sync', opts].reject(&:empty?).join(' ')
    reply[:exitcode] = run cmd, stdout: :out, stderr: :err,
                                chomp: true
    reply[:stdout]   = :out
    reply[:stderr]   = :err
  end
end
