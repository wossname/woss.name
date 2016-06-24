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
