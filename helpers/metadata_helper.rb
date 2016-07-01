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

  def title_meta(page = current_page)
    strip_whitespace(page.data.title || config[:title])
  end

  def description_meta(page = current_page)
    strip_whitespace(strip_tags(page.data.description || config[:default_description]))
  end

  def category_meta(page = current_page)
    page.data.category || config[:default_category]
  end

  def tags_meta(page = current_page)
    (page.data.tags || config[:default_tags] || []) + (config[:site_tags] || []).sort
  end

  def published_on_meta(page = current_page)
    if (published_on = page.data[:published_on])
      published_on.acts_like?(:date) ? published_on : Date.parse(published_on)
    else
      last_modified(page)
    end
  end

  def updated_on_meta(page = current_page)
    if (updated_on = page.data[:updated_on])
      updated_on.acts_like?(:date) ? updated_on : Date.parse(updated_on)
    else
      published_on_meta(page)
    end
  end

  def canonical_url_meta(page = current_page)
    url = if (canonical_source = page.data.canonical_source)
      canonical_source[:url]
    else
      page.url
    end

    url_for(url, absolute: true)
  end

  def alternate_urls_meta(page, options = {})
    if (alternates = page.data.alternates)
      alternates.map { |source| url_for source[:url], options }
    else
      []
    end
  end

  def open_graph_image_tags(image)
    width, height, type = properties_for_image(image)

    tags = [
      meta_tag(property: 'og:image', content: image_path(image, absolute: true))
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
end
