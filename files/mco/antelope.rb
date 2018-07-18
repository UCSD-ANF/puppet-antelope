# frozen_string_literal: true

module MCollective
  module Agent
    class Antelope < RPC::Agent
      activate_when do
        File.executable?('/usr/local/bin/antelope_sync')
      end

      action 'sync' do
        mode = request[:mode] || @config.pluginconf.fetch('antelope.sync_mode',
                                                          'normal')
        case mode
        when 'dry-run'
          opts = '-n'
        when 'nostopstart'
          opts = '-S'
        when 'norestart'
          opts - '-s'
        else
          opts = ''
        end
        cmd = ['/usr/local/bin/antelope_sync', opts].reject(&:empty?).join(' ')
        reply[:exitcode] = run cmd, stdout: :out, stderr: :err,
                                    chomp: true
        reply[:stdout]   = :out
        reply[:stderr]   = :err
      end
    end
  end
end
