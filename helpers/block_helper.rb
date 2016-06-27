module BlockHelper
  def block(title: nil, id: nil, vertical_alignment: false, &block)
    id ||= parameterize(title)
    partial 'blocks/block', locals: { id: id, title: title, vertical_alignment: vertical_alignment }, &block
  end

  def introduction(title: current_page.data.title, &b)
    block title: title, id: :introduction, vertical_alignment: :middle, &b
  end
  
  def listing(&block)
    partial 'blocks/listing', &block
  end

  def featured_list_item(title: nil, subtitle: nil, icon: nil, id: nil, &block)
    id ||= parameterize(title)
    icon = parameterize(icon)

    partial 'feature_list_item', locals: { id: id, title: title, subtitle: subtitle, icon: icon }, &block
  end
end