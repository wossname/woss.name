module ArticleHelper
  def published_on_tag(page = current_page)
    time_tag published_on_meta(page)
  end

  def updated_on_tag(page = current_page)
    time_tag updated_on_meta(page)
  end

  def excerpt_with_link(article)
    excerpt = excerpt(article)
    link = link_to 'Read more&hellip;', article.url

    [ excerpt, link ].join(' ')
  end

  def article_tags(article)
    (article.data.tags || []).map(&:downcase).sort.uniq
  end

  private

  def excerpt(article)
    article.data.excerpt || article_paragraphs(article).first
  end

  # Select all the paragraphs from the body text which are actual paragraphs
  # (ie not headings). It's probably not an entirely accurate algorithm, but
  # I think it's good enough for extracting the first paragraph to use as
  # an excerpt.
  def article_paragraphs(article)
    source = article.file_descriptor.read
    body = source.split("---\n", 3).last

    body.split(/\n{2,}/).select { |paragraph| paragraph !~ /^#/ }
  end

  def article_slug(article)
    File.basename(article.source_file).gsub(/\..*$/, '')
  end
end
