require 'rake/clean'

CLEAN.include 'build'

task default: :build

desc 'Install all the dependencies required to build and deploy the site.'
task :deps do
  bundle :install
  npm :install
end

desc 'Build the web site and output the contents in the build/ folder.'
task :build do
  middleman :build
end

desc 'Launch an interactive console with Middleman loaded.'
task :console do
  middleman :console
end

desc 'Serve up the site locally, for development.'
task :serve do
  sh 'foreman start'
end

# Helper methods to run external tasks.
def run(command, *args)
  sh "#{command} #{args.join(' ')}"
end

def bundle(command, *args)
  run :bundle, command, *args
end

def middleman(command, *args)
  args << '--verbose' if verbose == true

  bundle :exec, :middleman, command, *args
end

def npm(command, *args)
  run :npm, command, *args
end
