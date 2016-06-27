module BootstrapHelper
  def navbar_link_to(title, path, options = {})
    current = (path == "/#{current_page.path}")
    content_for :navbar, "<li#{current ? ' class="active"' : ''}>#{link_to title, path, options}</li>"
  end

  def markdown(text)
    Tilt['markdown'].new { text }.render
  end
  
  def entypo(icon, options = {})
    icon = parameterize(icon)
    classes = options.delete(:class) || []
    classes += [ 'icon', "icon-#{icon}" ]

    tag :span, { class: classes.join(' ') }.merge(options)
  end
end
