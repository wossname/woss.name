module SitemapHelper
  def sitemap_pages
    sitemap.resources.find_all { |resource| resource.content_type =~ /text\/html/ }
  end

  def last_modified(page)
    File.mtime(page.source_file)
  end

  def xml_timestamp(dateish = Time.now)
    timestamp = dateish.respond_to?(:strftime) ? dateish : Date.parse(dateish)
    timestamp.strftime('%FT%H:%M:%S%:z')
  end
end
