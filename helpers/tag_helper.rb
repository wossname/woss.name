module TagHelper
  def link_to_tag(tag, options = {})
    url_options = options.slice(:absolute)
    link_to_options = options.except(:absolute)

    link_to tag, tag_path(tag, url_options), { rel: :tag }.merge(link_to_options)
  end

  def tag_path(tag, options = {})
    url_for "/tags/#{tag_slug(tag)}/index.html", options
  end

  def description_for_tag(name)
    if (tag = find_tag_by_name(name))
      tag[:description]
    end
  end

  private

  def find_tag_by_name(name)
    data.tags[tag_slug(name)]
  end

  def tag_slug(name)
    parameterize(name)
  end
end
