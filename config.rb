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
