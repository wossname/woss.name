module BlockHelper
  def block(title: nil, id: nil, vertical_alignment: false, inverse: false, &block)
    id ||= parameterize(title)
    partial 'partials/block', locals: { id: id, title: title, vertical_alignment: vertical_alignment, inverse: inverse }, &block
  end

  def introduction(title: current_page.data.title, &b)
    block title: title, id: :introduction, vertical_alignment: :middle, &b
  end

  def listing(id: nil, &b)
    block id: id, &b
  end

  def featured_list_item(title: nil, subtitle: nil, icon: nil, id: nil, url: nil, &block)
    id ||= parameterize(title)
    icon = parameterize(icon)

    partial 'partials/feature_list_item', locals: { id: id, title: title, subtitle: subtitle, icon: icon, url: url }, &block
  end
end
