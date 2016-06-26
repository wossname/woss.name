module MetadataHelper
  def title_meta
    strip_whitespace(current_page.data.title || config[:title])
  end

  def description_meta
    strip_whitespace(strip_tags(current_page.data.description || config[:default_description]))
  end

  def category_meta
    current_page.data.category || config[:default_category]
  end

  def link_to_category(category, options = {})
    link_to category, category_path(category), { rel: [ :section, :category ].join(' ') }.merge(options)
  end

  def category_path(category)
    "/categories/#{parameterize(category)}/index.html"
  end

  def description_for_category(name)
    slug, category = data.categories.find { |_, category| category[:name] == name }
    if category
      category[:description]
    else
      ''
    end
  end

  def tags_meta
    (current_page.data.tags || config[:default_tags] || []) + (config[:site_tags] || []).sort
  end

  def link_to_tag(tag, options = {})
    link_to tag, tag_path(tag), { rel: :tag }.merge(options)
  end

  def tag_path(tag)
    "/tags/#{parameterize(tag)}/index.html"
  end

  def published_on_meta
    if (published_on = current_page.data.published_on)
      published_on.acts_like?(:date) ? published_on : Date.parse(published_on)
    else
      # FIXME: This should pull the last modified time from Git/the filesystem.
      Date.today
    end
  end

  def published_on_tag
    time_tag published_on_meta
  end

  def updated_on_meta
    if (updated_on = current_page.data.updated_on)
      Date.parse(updated_on)
    else
      published_on_meta
    end
  end

  def updated_on_tag
    time_tag updated_on_meta
  end

  def canonical_url_meta
    if (canonical_source = current_page.data.canonical_source)
      canonical_url = canonical_source[:url]
      canonical_url.start_with?('/') ? "#{config[:url]}#{canonical_url}" : canonical_url
    else
      "#{config[:url]}#{current_page.url}"
    end
  end

  def alternate_urls_meta
    if (alternates = current_page.data.alternates)
      alternates.map { |source| source[:url] }
    else
      []
    end
  end

  def open_graph_image_tags(image)
    width, height = dimensions_for_image(image)

    tags = [
      meta_tag(property: 'og:image', content: image_path(image)),
      meta_tag(property: 'og:image:type', content: 'image/png')
    ]

    tags << meta_tag(property: 'og:image:width', content: width) if width
    tags << meta_tag(property: 'og:image:height', content: height) if height

    tags.join("\n")
  end

  def meta_tag(options = {})
    tag :meta, options
  end

  def dimensions_for_image(path)
    path = File.join(config[:images_dir], path) unless path.start_with?('/')
    file = app.files.find(:source, path) || app.files.find(:source, path.sub(/^\//, ''))
    full_path = file[:full_path].to_s

    ::FastImage.size(full_path, raise_on_failure: true)
  rescue FastImage::UnknownImageType
    []
  rescue
    warn "Couldn't determine dimensions for image #{path}: #{$ERROR_INFO.message}"
    []
  end

  def strip_whitespace(str)
    if str.blank?
      ''
    else
      str.split(/\n/).map(&:strip).join(' ')
    end
  end
end
