# frozen_string_literal: true

# MCollective Agent for BRTT Antelope
#
# Defines a single action, called sync.
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
