module TextHelper
  # FIXME: This isn't actually escaping anything, it's just stripping what
  # might be considered invalid...
  def xml_escape(str)
    if str.blank?
      ''
    else
      strip_entities(plaintext(str))
    end
  end

  def plaintext(str)
    strip_whitespace(strip_tags(markdown(str)))
  end

  def strip_whitespace(str)
    if str.blank?
      ''
    else
      str.split(/\n/).map(&:strip).join(' ')
    end
  end

  def strip_entities(str)
    str.gsub(/&[^;]+;/, '')
  end
end
