require 'mechanize'

class TorrentzPage < ActiveRecord::Base

  validates_uniqueness_of :url
  
  # Store a mechanize agent as a class instance variable
  @agent = nil
  class << self
    def agent
      return @agent unless @agent.nil?
      @agent = WWW::Mechanize.new 
    end
  end
  
  SITE_URL = 'http://torrentz.com/'
  VERIFIED_URL = 'http://torrentz.com/verified?q=movie'
  SRC_REGEX = /(<[^>]*?src=["\'])([^\'"]*?)(["\'][^>]*?>)/mi
  HREF_REGEX = /(<[^>]*?href=["\'])([^\'"]*?)(["\'][^>]*?>)/mi
  IFRAME_REGEX = /<iframe[^>]*?>.*?<\/iframe>/mi
  HEAD_REGEX = /(<head[^>]*>)(.*?)(<\/head>)/mi
  PASS_THROUGH_LINKS = /q=movie/
  
  # Return a TorrentzPage instance for these search parameters
  def self.get(url=nil)
    
    # Try to find a saved copy
    url ||= TorrentzPage::VERIFIED_URL
    tzpage = TorrentzPage.find(:first, :conditions => { :url => url })
    
    # If we haven't got one, or if it's old, download it
    if tzpage.nil? or tzpage.html.nil? or tzpage.updated_at <= 5.minutes.ago
      tzpage ||= TorrentzPage.new(:url => url)
      tzpage.load
      tzpage.save
    end
    tzpage
  end
  
  # Load the torrentz page and store it in this instance
  def load 
    logger.info "Downloading URL #{self.url}"
    html = self.class.agent.get(self.url).body
    self.html = self.processPage(html)
  end
  
  # Rewrite the links on the page, insert some items in the head
  def processPage(html)
    
    # Prepend all SRC links with the torrentz URL
    html.gsub!(SRC_REGEX) do |m|
      src = $2[0].chr == '/' ? $2[1..-1] : $2
      "#{$1}#{TorrentzPage::SITE_URL}#{src}#{$3}"
    end
   
    # Prepend *most* HREF links with the torrentz URL, allow some to pass through
    html.gsub!(HREF_REGEX) do |m|
      src = $2[0].chr == '/' ? $2[1..-1] : $2
      prepended = "#{$1}#{TorrentzPage::SITE_URL}#{src}#{$3}"
      if m.match(PASS_THROUGH_LINKS)
        m
      else
        prepended
      end
    end
    
    # Remove iframes
    html.gsub!(IFRAME_REGEX, '')
    
    # Add our javascript include to the head
    html = html.match(HEAD_REGEX) do |m|
      script = '<script type="text/javascript" src="/javascripts/torrentz.js"></script>'
      "#{$1}#{$2}#{script}#{$3}"
    end
    
    html 
  end
end
