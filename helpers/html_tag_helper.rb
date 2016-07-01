require 'active_support/core_ext/date'
require 'active_support/time_with_zone'

module HtmlTagHelper
  def time_tag(date_or_time, title_or_options = nil, options = nil, &block)
    datetime = date_or_time.acts_like?(:time) ? date_or_time.xmlschema : date_or_time.iso8601

    if block_given?
      options = title_or_options || {}

      content_tag :time, { datetime: datetime }.merge(options), &block
    else
      options ||= {}

      if title_or_options.is_a?(Hash)
        title = nil
        options = title_or_options
      else
        title = title_or_options
      end

      format = options.delete(:format) || :long
      title ||= date_or_time.to_s(format)

      content_tag :time, title, { datetime: datetime }.merge(options)
    end
  end

  def meta_tag(options = {})
    tag :meta, options
  end

  def label(type, &block)
    content_tag :span, class: "label label-#{type}", &block
  end
end
