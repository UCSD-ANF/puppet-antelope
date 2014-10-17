begin
  require 'rubygems'
  require 'puppetlabs_spec_helper/rake_tasks'
  require 'ci/reporter/rake/rspec'
rescue LoadError => e
  STDERR.puts "An error occurred loading dependencies for the Rakefile:"
  STDERR.puts e.message
  STDERR.puts "Please install all dependencies with the `bundle`command first"
  STDERR.puts ["If this error message continues after updating the bundle,",
               "a required library may no longer be compatible"].join(' ')
  exit
end
