require 'active_support/inflector'

module LinkHelper
  def url_for(path_or_resource, options = {})
    absolute = options.key?(:absolute) ? options.delete(:absolute) : (current_page.data[:absolute_urls] || config[:relative_urls])
    relative = options.key?(:relative) ? options[:relative] : config[:relative_links]

    raise "Can't have relative and absolute URLs together!" if absolute && relative

    url = super

    if absolute && url.start_with?('/')
      "#{config[:url]}#{url}"
    else
      url
    end
  end

  def image_path(path_or_resource, options = {})
    absolute = options.key?(:absolute) ? options.delete(:absolute) : (current_page.data[:absolute_urls] || config[:relative_urls])
    relative = options.key?(:relative) ? options[:relative] : config[:relative_links]

    raise "Can't have relative and absolute URLs together!" if absolute && relative

    url = super(path_or_resource)

    if absolute && url.start_with?('/')
      "#{config[:url]}#{url}"
    else
      url
    end
  end

  def mail_to_link(title_or_options = {}, maybe_options = nil, &block)
    if maybe_options.nil?
      if title_or_options.is_a?(Hash)
        title   = nil
        options = title_or_options
      else
        title = title_or_options
        options = {}
      end
    else
      title = title_or_options
      options = maybe_options
    end

    if block_given?
      title = capture_html(&block)
    end

    email_address = options.delete(:email_address) || config[:default_email_address]

    output = mail_to email_address, title || email_address, options

    block_is_template?(block) ? concat_content(output) : output
  end

  def utm_link_to(title_or_url, url_or_options = nil, options = {}, &block)
    if block_given?
      title       = capture_html(&block)
      plain_title = strip_tags(title).strip
      url         = title_or_url
      options     = url_or_options || {}
    else
      title       = title_or_url
      plain_title = title
      url         = url_or_options
      options     = options
    end

    utm_source   = parameterize(options.delete(:source)   || config[:default_utm_source])
    utm_medium   = parameterize(options.delete(:medium)   || config[:default_utm_medium])
    utm_campaign = parameterize(options.delete(:campaign) || config[:default_utm_campaign])
    utm_content  = parameterize(options.delete(:content)  || plain_title)

    query = {
      utm_source:   utm_source,
      utm_medium:   utm_medium,
      utm_campaign: utm_campaign,
      utm_content:  utm_content
    }.merge(options.delete(:query) || {}).reject { |k, v| v.blank? }

    options = { query: query, title: plain_title }.merge(options)

    output = link_to title, url, options

    block_is_template?(block) ? concat_content(output) : output
  end

  def link_to_instapaper(title_or_resource, resource_or_options = nil, options = {}, &block)
    if block_given?
      title    = nil
      resource = title_or_resource
      options  = resource_or_options || {}
    else
      title    = title_or_resource
      resource = resource_or_options
      options  = options
    end

    url = 'http://www.instapaper.com/hello2'
    query = {
      url: url_for(resource.url, absolute: true),
      title: resource.data.title,
      description: excerpt(resource)
    }
    options = { query: query }.merge(options)

    if block_given?
      link_to url, options, &block
    else
      link_to title, url, options
    end
  end

  def amazon_url_for(asin, store = :uk)
    affiliate_tag = affiliate_tag(:amazon, store)

    case store
    when :uk
      "http://www.amazon.co.uk/gp/product/#{asin}/ref=as_li_tl?ie=UTF8&camp=1634&creative=19450&creativeASIN=#{asin}&linkCode=as2&tag=#{affiliate_tag}"
    else
      raise "FIXME: Need to generate Amazon product URLs for other stores."
    end
  end

  def affiliate_tag(company, store = nil)
    tags = (config[:affiliate_tags] || {})[company]
    if tags.is_a?(Hash) && store
      tags[store]
    else
      tags
    end
  end
end
