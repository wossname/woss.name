# Defaults for the site.
config[:domain]                = 'woss.name'
config[:url]                   = "https://#{config[:domain]}"
config[:default_email_address] = "hello@#{config[:domain]}"
config[:default_utm_source]    = config[:domain]
config[:default_utm_medium]    = 'website'
config[:default_utm_campaign]  = 'Wossname Industries website'

# Defaults for metadata that can be overridden on pages with more specific
# content.
config[:company]          = 'Wossname Industries'
config[:title]            = config[:company]
config[:copyright]        = "Copyright &copy; 2015-#{Date.today.year} #{config[:company]}. All rights reserved."
config[:default_category] = 'Software Development'
config[:default_tags]     = [ 'Ruby', 'Rails', 'Ruby on Rails', 'iOS', 'iPhone',
                              'iPad', 'Swift', 'DevOps', 'Consulting' ]
config[:gravatar]         = "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(config[:default_email_address])}"
config[:telephone]        = "+44 (0)7949 077744"
config[:logo]             = 'wossname-industries.png'
config[:twitter_owner]    = 'wossname'
config[:twitter_creator]  = 'mathie'

config[:default_description] = <<-TEXT
  Wossname Industries is Graeme Mathieson's software consultancy. We build
  Ruby on Rails web apps, iOS apps, and the DevOps-ian infrastructure to manage
  it all.
TEXT

# Identifiers for various other services.
config[:gtm_id]         = 'GTM-KLSLNV'
config[:google_plus_id] = '103001545622534344345'
config[:fb_app_id]      = '619490114749622'
config[:related]        = {
  twitter:  'https://twitter.com/wossname',
  facebook: 'https://www.facebook.com/wossname-industries',
  google:   'https://plus.google.com/+WossnameIndustries',
  linkedin: 'https://www.linkedin.com/company/wossname-industries',
  github:   'https://github.com/wossname'
}

# Pages with no layout.
[ :xml, :json, :txt ].each do |extension|
  page "/*.#{extension}", layout: false
end

# General configuration
activate :directory_indexes
activate :asset_hash
activate :gzip
activate :automatic_image_sizes
activate :relative_assets

activate :external_pipeline,
  name: :gulp,
  command: "npm #{build? ? 'run build' : 'start'}",
  source: 'dist/'

ignore 'stylesheets/all'

# Local development-specifc configuration.
configure :development do
  # Reload the browser automatically whenever files change.
  activate :livereload
end

# Build-specific configuration
configure :build do
  activate :minify_html
end

activate :s3_sync do |s3|
  s3.bucket                = 'woss.name'
  s3.aws_access_key_id     = ENV['AWS_ACCESS_KEY_ID']
  s3.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
end

activate :cloudfront do |cf|
  cf.access_key_id     = ENV['AWS_ACCESS_KEY_ID']
  cf.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  cf.distribution_id   = 'E2FX3CW8SS3ZGF'
  cf.filter            = /\.(html|xml|txt)$/
end

# Set cache-control headers to revalidate pages, but everything else is
# asset-hashed, so can live forever.
caching_policy 'text/html',       max_age: 0, must_revalidate: true
caching_policy 'application/xml', max_age: 0, must_revalidate: true
caching_policy 'text/plain',      max_age: 0, must_revalidate: true

default_caching_policy max_age: (60 * 60 * 24 * 365)
