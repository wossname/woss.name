module MetadataHelper
  def title_meta
    strip_whitespace(current_page.data.title || config[:title])
  end

  def description_meta
    strip_whitespace(current_page.data.description || config[:default_description])
  end

  def category_meta
    current_page.data.category || config[:default_category]
  end

  def tags_meta
    (current_page.data.tags || config[:default_tags] || []) + (config[:site_tags] || [])
  end

  def published_at_meta
    current_page.data.published_at || Time.now
  end

  def updated_at_meta
    current_page.data.updated_at || published_at_meta
  end

  def url_meta
    "#{config[:url]}#{current_page.url}"
  end

  def strip_whitespace(str)
    if str.blank?
      ''
    else
      str.split(/\n/).map(&:strip).join(' ')
    end
  end
end
