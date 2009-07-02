# == Schema Information
# Schema version: 20090627051844
#
# Table name: torrentz_pages
#
#  id         :integer         not null, primary key
#  html       :text
#  params     :string(255)
#  url        :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

require 'mechanize'

class TorrentzPage < ActiveRecord::Base

  attr_accessor :movies
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
  VERIFIED_URL = 'http://torrentz.com/verified?q=movie&p=0'
  SITE_URL_REGEX = /^http:\/\/torrentz.com\//mi
  SRC_REGEX = /(<[^>]*?src=["\'])([^\'"]*?)(["\'][^>]*?>)/mi
  HREF_REGEX = /(<[^>]*?href=["\'])([^\'"]*?)(["\'][^>]*?>)/mi
  STYLE_URL_REGEX = /(style=["\'].*\surl\(["\'])([^\'"]*?)(["\']\))/mi
  TORRENT_MOVIE_REGEX = /<[^>]*?href=["\'](http:\/\/torrentz.com\/([a-z0-9]{40}?))["\'][^>]*?>(.*?)<\/a>/i
  IFRAME_REGEX = /<iframe[^>]*?>.*?<\/iframe>/mi
  HEAD_REGEX = /(<head[^>]*>)(.*?)(<\/head>)/mi
  PASS_THROUGH_LINKS = /q=movie/
  HEAD_INCLUDE = <<-INCLUDE.strip
    <link type="text/css" href="/stylesheets/torrentz.css" rel="stylesheet" />\
    <script type="text/javascript" src="/javascripts/jquery-1.3.2.min.js"></script>\
    <script type="text/javascript" src="/javascripts/torrentz.js"></script>
    INCLUDE
  
  # Return a TorrentzPage instance for these search parameters
  def self.findOrCreate(url=nil)
    
    # Try to find a saved copy
    url ||= TorrentzPage::VERIFIED_URL
    tzpage = TorrentzPage.find(:first, :conditions => { :url => url }, :lock => true)
    
    # If we haven't got one, download it
    if tzpage.nil?
      tzpage = TorrentzPage.create(:url => url).lock!
    end
    
    if tzpage.html.nil?
      tzpage.downloadUrl
      tzpage.extractMovies
      tzpage.save
    end
    tzpage
  end
  
  # Load the torrentz page and store it in this instance
  def downloadUrl 
    logger.info "Downloading URL #{self.url}"
    self.html = self.class.agent.get(self.url).body
    self.processPage
  end
  
  # Extract the movie links, titles and hashes from the html and
  # store them in an instance variable
  def extractMovies(htmlarg=nil)
    html = htmlarg.nil? ? self.html : htmlarg
    movies = html.scan(TORRENT_MOVIE_REGEX)
    self.movies = movies if htmlarg.nil?
    movies
  end
    
  # Rewrite the links on the page, insert some items in the head
  def processPage(htmlarg=nil)
    html = htmlarg.nil? ? self.html : htmlarg
    
    # Prepend all SRC links with the torrentz URL
    html.gsub!(SRC_REGEX) do |m|
      src = $2[0].chr == '/' ? $2[1..-1] : $2
      prepended = "#{$1}#{TorrentzPage::SITE_URL}#{src}#{$3}"
      if $2.match(SITE_URL_REGEX)
        m
      else
        prepended
      end
    end
    
    # Prepend all CSS urls with the torrentz URL
    html.gsub!(STYLE_URL_REGEX) do |m|
      src = $2[0].chr == '/' ? $2[1..-1] : $2
      prepended = "#{$1}#{TorrentzPage::SITE_URL}#{src}#{$3}"
      if $2.match(SITE_URL_REGEX)
        m
      else
        prepended
      end
    end
    
    # Prepend *most* HREF links with the torrentz URL, allow some to pass through
    html.gsub!(HREF_REGEX) do |m|
      src = $2[0].chr == '/' ? $2[1..-1] : $2
      prepended = "#{$1}#{TorrentzPage::SITE_URL}#{src}#{$3}"
      link = $2
      if link.match(SITE_URL_REGEX) or m.match(PASS_THROUGH_LINKS)
        m
      else
        prepended
      end
    end
    
    # Remove iframes
    html.gsub!(IFRAME_REGEX, '')
    
    # Add our javascript include to the head.  Call after removing iframes.
    html.sub!(HEAD_REGEX) do |m|
      "#{$1}#{$2}#{TorrentzPage::HEAD_INCLUDE}#{$3}"
    end
    
    self.html = html if htmlarg.nil?
    html 
  end
end
