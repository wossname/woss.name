# Defaults for the site.
config[:domain]                = 'woss.name'
config[:default_email_address] = "hello@#{config[:domain]}"
config[:default_utm_source]    = config[:domain]
config[:default_utm_medium]    = 'website'
config[:default_utm_campaign]  = 'Wossname Industries website'

# Defaults for metadata that can be overridden on pages with more specific
# content.
config[:company]          = 'Wossname Industries'
config[:legal_entity]     = "#{config[:company]} Ltd"
config[:title]            = config[:company]
config[:copyright]        = "Copyright &copy; 2015-#{Date.today.year} #{config[:company]}. All rights reserved."
config[:default_category] = 'Software Development'
config[:default_tags]     = [ 'Ruby', 'Rails', 'Ruby on Rails', 'iOS', 'iPhone',
                              'iPad', 'Swift', 'DevOps', 'Consulting' ]
config[:telephone]        = "+44 (0)7949 077744"
config[:logo]             = 'wossname-industries.png'
config[:twitter_owner]    = 'wossname'
config[:twitter_creator]  = 'mathie'

config[:default_description] = <<-TEXT
  Wossname Industries is Graeme Mathieson's software consultancy. I build
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

config[:affiliate_tags] = {
  amazon: {
    uk: 'wossname-21'
  }
}

# Pages with no layout.
[ :xml, :json, :txt ].each do |extension|
  page "/*.#{extension}", layout: false
end

page "/articles/*.html", layout: :article, data: {
  sitemap_priority: 1.0,
  sitemap_changefreq: 'weekly'
}

page "/articles.html",   layout: :collection
page "/categories.html", layout: :collection
page "/tags.html",       layout: :collection
page "/blog*",           directory_index: false

# And some artefacts of previous incarnations of the site.
redirect 's/keybase.txt',            to: '/keybase.txt'
redirect 'hire_me.html',             to: '/services.html'
redirect 'page/2.html',              to: '/articles.html'
redirect 'author/mathie.html',       to: 'team/mathie.html'
redirect 'team.html',                to: 'team/mathie.html'
redirect 'contributor/7068656.html', to: 'team/mathie.html'
redirect 'contributor/7068769.html', to: 'team/mathie.html'
redirect 'display/Login.html',       to: '/index.html'
redirect 'splash.html',              to: '/index.html'
redirect 'software/PloneCC.html',    to: 'https://github.com/mathie/PloneCC'
redirect 'software/PloneAtom.html',  to: 'https://github.com/mathie/PloneAtom'

# Old Wordpress categories.
redirect 'category/geekery/software-configuration-management.html', to: '/categories/internet.html'
redirect 'category/geekery/solaris.html',                           to: '/categories/internet.html'
redirect 'category/geekery/mac-os-x.html',                          to: '/categories/internet.html'
redirect 'category/geekery/ruby-and-rails.html',                    to: '/categories/software-development.html'

# NaNoWriMo articles I initially published separately.
redirect "nanowrimo.html", to: "/articles.html"
[ 'personal-code-review', 'planning', 'the-demise-of-the-gruffalo', 'the-inner-game-of-pool', 'walking' ].each do |slug|
  redirect "nanowrimo/articles/#{slug}.html", to: "/articles/#{slug}.html"
end

ready do
  include SitemapHelper

  # Might as well generate redirects for all articles from their hypothetical
  # old locations. Worst case, they're just unreferenced and never get seen.
  all_articles.each do |article|
    slug = article.path.gsub(/^articles\//, '').gsub(/\.html$/, '')
    prefix = article.data.published_on.strftime('%Y/%m/%d')

    redirect "#{slug}.html", to: "/articles/#{slug}.html"
    redirect "blog/#{prefix.gsub(/\/0/, '/')}/#{slug}.html", to: "/articles/#{slug}.html"
    redirect "#{prefix}/#{slug}.html", to: "/articles/#{slug}.html"
  end

  # Generate pages for each category.
  all_categories.each do |category|
    slug = parameterize(category)

    proxy "/categories/#{slug}/index.html", '/category.html', data: {
      title: "Articles posted in '#{category}'"
    }, locals: { name: category }, ignore: true
  end

  # And all the tags.
  all_tags.each do |tag|
    slug = parameterize(tag)

    proxy "/tags/#{slug}/index.html", '/tag.html', data: {
      title: "Articles tagged '#{tag}'"
    }, locals: { name: tag }, ignore: true
  end

  # FIXME: #proxy doesn't seem to cause the sitemap to update/rebuild/whatever,
  # so s3_sync isn't picking up these files. Running something that tweaks the
  # sitemap and causes it to be refreshed seems to do the trick. (As to why a
  # query on the sitemap rebuilds it, I don't know!). End result is that this
  # gets s3_sync to pick up the tag and category pages...
  all_tags
end

# General configuration
activate :directory_indexes
activate :asset_hash
activate :gzip
activate :automatic_image_sizes
activate :syntax

activate :external_pipeline,
  name: :gulp,
  command: "npm #{build? ? 'run build' : 'start'}",
  source: 'dist/'

# Since we're managing CSS through the external asset pipeline, ignore the less
# source internally.
ignore 'stylesheets/*.less'

set :markdown_engine, :redcarpet
set :markdown, smartypants: true, with_toc_data: true, footnotes: true,
  superscript: true, fenced_code_blocks: true, tables: true,
  no_intra_emphasis: true


# Local development-specifc configuration.
configure :development do
  # Reload the browser automatically whenever files change.
  activate :livereload

  config[:url] = "http://localhost:5000"
end

# Build-specific configuration
configure :build do
  activate :minify_html

  config[:url] = "https://#{config[:domain]}"
end

activate :s3_sync do |s3|
  s3.bucket                = config[:domain]
  s3.aws_access_key_id     = ENV['AWS_ACCESS_KEY_ID']
  s3.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
end

# Set cache-control headers to cache for 5 minutes, and revalidate pages, but everything else is asset-hashed, so can live forever.
caching_policy 'text/html',       max_age: 300, must_revalidate: true, public: true
caching_policy 'application/xml', max_age: 300, must_revalidate: true, public: true
caching_policy 'text/plain',      max_age: 300, must_revalidate: true, public: true

default_caching_policy max_age: (60 * 60 * 24 * 365)
