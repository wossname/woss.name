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

  def image_for(page, type)
    page.data[:image] && page.data[:image][type]
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

  private

  def find_file(path)
    app.files.find(:source, path) || app.files.find(:source, path.sub(/^\//, ''))
  end
end
