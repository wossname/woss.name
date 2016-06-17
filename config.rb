# Pages with no layout.
[ :xml, :json, :txt ].each do |extension|
  page "/*.#{extension}", layout: false
end

# General configuration

# Local development-specifc configuration.
configure :development do
  # Reload the browser automatically whenever files change.
  activate :livereload
end

# Build-specific configuration
configure :build do
end
