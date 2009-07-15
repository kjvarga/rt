#
# Extend the built-in String class.
#

require 'cgi'

class String
  def to_safe_uri
    CGI::escape(self.strip.downcase.gsub('&', 'and').gsub(' ', '-').gsub(/[^\w-]/,''))
  end
end