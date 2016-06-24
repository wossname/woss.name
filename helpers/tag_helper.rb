require 'active_support/core_ext/date'
require 'active_support/time_with_zone'

module TagHelper
  def time_tag(date_or_time, title_or_options = nil, options = {}, &block)
    datetime = date_or_time.acts_like?(:time) ? date_or_time.xmlschema : date_or_time.iso8601

    if block_given?
      options = title_or_options || {}

      content_tag :time, { datetime: datetime }.merge(options), &block
    else
      format = options.delete(:format) || :long
      title  = title_or_options || date_or_time.to_s(format)

      content_tag :time, title, { datetime: datetime }.merge(options)
    end
  end
end
