module TextHelper
  def xml_escape(str)
    if str.blank?
      ''
    else
      strip_whitespace(strip_tags(markdown str))
    end
  end

  def strip_whitespace(str)
    if str.blank?
      ''
    else
      str.split(/\n/).map(&:strip).join(' ')
    end
  end
end
