module ImageHelper
  def thumbnail_image_for(page)
    image_for(page, :thumbnail)
  end

  def square_image_for(page)
    image_for(page, :square)
  end

  def cover_image_for(page)
    image_for(page, :cover)
  end

  def image_for(article, type)
    slug = article_slug(article)
    basename = File.join(config[:images_dir], slug, type.to_s)

    if (image_path = find_file("#{basename}.png") || find_file("#{basename}.jpg"))
      image_path.relative_path.to_s.gsub(/^#{config[:images_dir]}\//, '')
    end
  end

  def properties_for_image(path)
    path = File.join(config[:images_dir], path) unless path.start_with?('/')
    file = find_file(path)
    full_path = file[:full_path].to_s

    width, height = ::FastImage.size(full_path, raise_on_failure: true)
    type = ::FastImage.type(full_path)

    [ width, height, type ]
  rescue FastImage::UnknownImageType
    []
  rescue
    warn "Couldn't determine dimensions for image #{path}: #{$ERROR_INFO.message}"
    []
  end

  def figure(image, caption: nil, alt: nil)
    alt ||= caption

    content_tag :figure, class: 'panel panel-warning' do
      body = content_tag :div, class: 'panel-body center-block' do
        image_tag(image_path("#{article_slug(current_page)}/#{image}", absolute: true), alt: alt, class: 'img-responsive img-rounded center-block', data: { action: 'zoom' })
      end

      if caption
        caption_tag = content_tag :figcaption, caption, class: 'panel-footer text-center'
        body + caption_tag
      else
        body
      end
    end
  end

  private

  def find_file(path)
    app.files.find(:source, path) || app.files.find(:source, path.sub(/^\//, ''))
  end

end
