require 'rake/clean'

CLEAN.include 'build'

task default: :build

desc 'Install all the dependencies required to build and deploy the site.'
task :deps do
  bundle :install
end

task :build do
  middleman :build
end

# Helper methods to run external tasks.
def bundle(command, *args)
  sh "bundle #{command} #{args.join(' ')}"
end

def middleman(command, *args)
  args << '--verbose' if verbose == true

  bundle :exec, :middleman, command, *args
end
