module SitemapHelper
  def all_articles(options = {})
    order = (options.delete(:order) || :published_on).to_s

    sitemap.resources.select { |resource| resource.path =~ /^articles\// }.sort { |a, b| b.data[order] <=> a.data[order] }
  end

  def latest_article(options = {})
    options[:order] ||= :published_on

    all_articles(options).first
  end

  def all_categories
    sitemap.resources.map { |resource| resource.data[:category] }.compact.sort.uniq
  end

  def all_tags
    sitemap.resources.map { |resource| resource.data[:tags] }.to_a.compact.flatten.sort { |a, b| a.downcase <=> b.downcase }.uniq
  end

  def articles_for_category(category, options = {})
    all_articles(options).select { |resource| (resource.data[:category] || '').downcase == category.downcase }
  end

  def articles_for_tag(tag, options = {})
    all_articles(options).select { |resource| (resource.data[:tags] || []).map(&:downcase).include?(tag.downcase) }
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

  def rfc822_timestamp(dateish = Time.now)
    timestamp = dateish.respond_to?(:rfc822) ? dateish : Date.parse(dateish)
    timestamp.rfc822
  end

  # This is blatantly stolen from ActiveSupport::Inflector#parameterize+. The
  # only thing I wanted to change is that I'm happy with '.' being in the
  # resulting string, since I'm using domain names for utm parameters... On the
  # flip side, I don't want underscores.
  def parameterize(string, sep = '-')
    return string if string.blank?
    string = string.to_s

    # replace accented chars with their ascii equivalents
    parameterized_string = ActiveSupport::Inflector.transliterate(string)
    # Turn unwanted chars into the separator
    parameterized_string.gsub!(/[^a-z0-9\-.]+/i, sep)
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      # No more than one of the separator in a row.
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      # Remove leading/trailing separator.
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/i, '')
    end
    parameterized_string.downcase
  end
end
