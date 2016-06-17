# Pages with no layout.
[ :xml, :json, :txt ].each do |extension|
  page "/*.#{extension}", layout: false
end

# General configuration
node_modules_path = File.expand_path('../node_modules', __FILE__)
gulp_bin_path     = File.join(node_modules_path, 'gulp', 'bin')
gulp              = File.join(gulp_bin_path, 'gulp.js')
activate :external_pipeline,
  name: :gulp,
  command: "#{gulp} #{build? ? 'build' : 'serve'}",
  source: 'dist/'

# Local development-specifc configuration.
configure :development do
  # Reload the browser automatically whenever files change.
  activate :livereload
end

# Build-specific configuration
configure :build do
end
