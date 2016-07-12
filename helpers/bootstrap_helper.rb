module BootstrapHelper
  def navbar_link_to(title, path, options = {})
    current = (path == "/#{current_page.path}")
    content_for :navbar, "<li#{current ? ' class="active"' : ''}>#{link_to title, path, options}</li>"
  end

  def markdown(text, erb: true)
    if erb
      text = Tilt['erb'].new { text }.render(self)
    end

    Tilt['markdown'].new { text }.render(self)
  end

  def entypo(icon, options = {})
    icon = parameterize(icon)
    classes = options.delete(:class) || []
    classes += [ 'icon', "icon-#{icon}" ]

    content_tag :span, '', { class: classes.join(' ') }.merge(options)
  end
end
