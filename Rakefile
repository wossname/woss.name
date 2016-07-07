require 'cgi'
require 'rake/clean'

CLEAN.include 'build', 'dist'
CLOBBER.include 'bower_components', 'node_modules', '.sass-cache'

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

desc 'Deploy the site to S3. Assumes you have AWS credentials in your environment. Assumes you have already run :build.'
task :deploy do
  middleman :sync
  middleman :invalidate

  rollbar

  Rake::Task['ping'].invoke
end

task :ping do
  domain = File.basename File.dirname(__FILE__)
  sitemap = "https://#{domain}/sitemap.xml"

  [
    'http://www.google.com/webmasters/tools/ping?sitemap=',
    'http://www.bing.com/ping?sitemap='
  ].each do |base_url|
    url = base_url + CGI.escape(sitemap)
    sh "curl '#{url}'"
  end
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

def rollbar
  environment   = 'production'
  rollbar_token = ENV['ROLLBAR_TOKEN']
  user          = ENV['USER']
  revision      = ENV['TRAVIS_COMMIT'] || `git log -n 1 --pretty = format:"%H"`.chomp

  sh "curl https://api.rollbar.com/api/1/deploy/ -F access_token=#{rollbar_token} -F environment=#{environment} -F revision=#{revision} -F local_username=#{user}"
end
