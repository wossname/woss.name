# If you do not have OpenSSL installed, change
# the following line to use 'http://'
source 'https://rubygems.org'

ruby File.read(File.expand_path('../.ruby-version', __FILE__)).chomp

# Rake is desired for managing all the tasks we have to run.
gem 'rake'

# For faster file watcher updates on Windows:
gem 'wdm', '~> 0.1.0', platforms: [:mswin, :mingw]

# Windows does not come with time zone data
gem 'tzinfo-data', platforms: [:mswin, :mingw, :jruby]

# Middleman Gems
gem 'middleman', '>= 4.0.0'
gem 'middleman-livereload'
gem 'middleman-minify-html'
gem 'middleman-syntax'

# Redcarpet seems to be the Markdown parser of choice.
gem 'redcarpet'

# FIXME: I shouldn't need less support in the Ruby side, since it's being built
# with the external pipeline, but Tilt is getting upset by the mere presence of
# a less file in the source tree.
gem 'less'
gem 'therubyracer'

# Deployment
gem 'middleman-cloudfront', github: 'andrusha/middleman-cloudfront'
gem 'middleman-s3_sync'
gem 'mime-types'

group :development do
  gem 'pry'
end
