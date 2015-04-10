metadata    :name        => 'antelope',
            :description => 'Interact with BRTT Antelope',
            :author      => 'Geoff Davis',
            :license     => 'BSD',
            :version     => '0.1',
            :url         => 'https://github.com/UCSD-ANF/puppet-antelope',
            :timeout     => 500

requires :mcollective => '2.2.1'

action 'sync', :description => 'run antelope_sync on a node' do
  input :mode,
    :prompt => 'Antelope Sync Mode',
    :description => 'One of: normal, dry-run, nostopstart, norestart',
    :type => :list,
    :optional => true,
    :list => ['normal', 'dry-run', 'nostopstart', 'norestart']

  output :stdout,
    :description => 'Standard Output from antelope_sync',
    :display_as  => 'Standard Output'

  output :stderr,
    :description => 'Standard Error from antelope_sync',
    :display_as  => 'Standard Error'

  output :exitcode,
    :description => 'The exitcode from the antelope_sync command',
    :display_as  => 'Exit Code'
end
