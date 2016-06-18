require 'active_support/inflector'

module LinkHelper
  def mail_to_link(title_or_options = {}, maybe_options = nil)
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

    email_address = options.delete(:email_address) || config[:default_email_address]

    mail_to email_address, title || email_address, options
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

  private

  # This is blatantly stolen from ActiveSupport::Inflector#parameterize+. The
  # only thing I wanted to change is that I'm happy with '.' being in the
  # resulting string, since I'm using domain names for utm parameters...
  def parameterize(string, sep = '-')
    return string if string.blank?

    # replace accented chars with their ascii equivalents
    parameterized_string = ActiveSupport::Inflector.transliterate(string)
    # Turn unwanted chars into the separator
    parameterized_string.gsub!(/[^a-z0-9\-_.]+/i, sep)
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
