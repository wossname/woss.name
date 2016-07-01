module CategoryHelper
  def link_to_category(category, options = {})
    title = options.delete(:title) || category
    url_options = options.slice(:absolute)
    link_to_options = options.except(:absolute)

    link_to title, category_path(category, url_options), { rel: [ :section, :category ].join(' ') }.merge(link_to_options)
  end

  def category_path(category, options = {})
    url_for "/categories/#{category_slug(category)}/index.html", options
  end

  def description_for_category(name)
    if (category = find_category_by_name(name))
      category[:description]
    else
      ''
    end
  end

  private

  def find_category_by_name(name)
    name = name.downcase

    data.categories.find { |_, category| category[:name].downcase == name }.second
  end

  def category_slug(name)
    parameterize(name)
  end
end
