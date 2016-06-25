module SitemapHelper
  def all_articles(options = {})
    order = (options.delete(:order) || :published_on).to_s

    sitemap.resources.select { |resource| resource.path =~ /^articles\// }.sort { |a, b| b.data[order] <=> a.data[order] }
  end

  def articles_for_category(category, options = {})
    order = (options.delete(:order) || :published_on).to_s

    sitemap.resources.select { |resource| resource.data['category'] == category }.sort { |a, b| b.data[order] <=> a.data[order] }
  end

  def articles_for_tag(tag, options = {})
    order = (options.delete(:order) || :published_on).to_s

    sitemap.resources.select { |resource| (resource.data['tags'] || []).include?(tag) }.sort { |a, b| b.data[order] <=> a.data[order] }
  end

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
