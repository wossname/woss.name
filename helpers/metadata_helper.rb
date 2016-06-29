module MetadataHelper
  def page_classes
    classes = super.split(' ')

    classess = classes.map do |klass|
      case klass
      when 'index'
        'landing-page'
      when /\A.*_(.*)_index\Z/
        $1
      when /\A^.*_(.*)\Z/
        $1
      else
        klass.gsub(/_/, '-')
      end
    end

    classess.join(' ')
  end

  def title_meta
    strip_whitespace(current_page.data.title || config[:title])
  end

  def description_meta
    strip_whitespace(strip_tags(current_page.data.description || config[:default_description]))
  end

  def category_meta
    current_page.data.category || config[:default_category]
  end

  def link_to_category(title_or_category, category_or_options = nil, options = nil)
    title = title_or_category

    if options.nil?
      if category_or_options.nil?
        category = title_or_category
        options = {}
      elsif category_or_options.is_a?(Hash)
        category = title_or_category
        options = category_or_options
      else
        category = category_or_options
        options = {}
      end
    else
      category = category_or_options
    end

    link_to title, category_path(category), { rel: [ :section, :category ].join(' ') }.merge(options)
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
    width, height, type = properties_for_image(image)

    tags = [
      meta_tag(property: 'og:image', content: "#{config[:url]}#{image_path(image)}")
    ]

    case type
    when :jpeg
      tags << meta_tag(property: 'og:image:type', content: 'image/jpeg')
    when :png
      tags << meta_tag(property: 'og:image:type', content: 'image/png')
    else
      warn "Couldn't figure out a MIME type for image: #{image}."
    end

    tags << meta_tag(property: 'og:image:width', content: width) if width
    tags << meta_tag(property: 'og:image:height', content: height) if height

    tags.join("\n")
  end

  def meta_tag(options = {})
    tag :meta, options
  end

  def properties_for_image(path)
    path = File.join(config[:images_dir], path) unless path.start_with?('/')
    file = app.files.find(:source, path) || app.files.find(:source, path.sub(/^\//, ''))
    full_path = file[:full_path].to_s

    width, height = ::FastImage.size(full_path, raise_on_failure: true)
    type = ::FastImage.type(full_path)
    
    [ width, heigh, type ]
  rescue FastImage::UnknownImageType
    []
  rescue
    warn "Couldn't determine dimensions for image #{path}: #{$ERROR_INFO.message}"
    []
  end

  def xml_escape(str)
    if str.blank?
      ''
    else
      strip_whitespace(strip_tags(markdown str))
    end
  end

  def strip_whitespace(str)
    if str.blank?
      ''
    else
      str.split(/\n/).map(&:strip).join(' ')
    end
  end
end
