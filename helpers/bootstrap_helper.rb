module BootstrapHelper
  def navbar_link_to(title, path, options = {})
    current = (path == "/#{current_page.path}")
    content_for :navbar, "<li#{current ? ' class="active"' : ''}>#{link_to title, path, options}</li>"
  end
end
