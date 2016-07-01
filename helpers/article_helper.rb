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

  private

  def excerpt(article)
    article.data.excerpt || article.data.description
  end
end
