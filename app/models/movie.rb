require 'cgi'
require 'nokogiri'

class Movie < ActiveRecord::Base
  
  # Store a mechanize agent as a class instance variable
  @agent = nil
  class << self
    def agent
      return @agent unless @agent.nil?
      @agent = WWW::Mechanize.new 
    end
  end
  
  ROTTEN_TOMATOES_SEARCH_URL = 'http://rottentomatoes.com/search/full_search.php?search='
  ROTTEN_TOMATOES_URL = 'http://www.rottentomatoes.com'
  EXTRACT_BODY_REGEX = Regexp.new('<body[^>]*>(.*?)</body>', Regexp::IGNORECASE|Regexp::MULTILINE)
  EXTRACT_MOVIE_INFO_REGEX = lambda { |inner_divs| 
    Regexp.new('(<div id="movie_info_box"[^>]*>(.*</div>){'+inner_divs.to_s+'}</div>)', 
        Regexp::IGNORECASE|Regexp::MULTILINE) 
  }
  
  #
  # Lookup a movie on RT and save its info
  #
  def lookupMovie
    
    # Validation
    if self.tz_title.nil?
      logger.warn "This movie doesn't have a title!"
      return
    end
    
    logger.debug 'Loading movie...' + self.inspect
    begin
      # Search for the movie and grab the first result
      logger.debug "Requesting the movie search URL..." 
      result = self.class.agent.get(Movie::ROTTEN_TOMATOES_SEARCH_URL + CGI::escape(self.tz_title))
      logger.debug "Parsing result of RT search..." 
      doc = Nokogiri::HTML(Movie::EXTRACT_BODY_REGEX.match(result.body)[0])
      row = doc.css('#search_results_main table tbody tr:first')
      self.rt_link = Movie::ROTTEN_TOMATOES_URL + row.css('td:first a')[0]['href']
      self.year = row.css('td:last strong')[0].text.strip unless row.css('td:last strong')[0].nil?

      # Load the movie page
      result = self.class.agent.get(self.rt_link)
      body = Movie::EXTRACT_BODY_REGEX.match(result.body)[0]
      doc = Nokogiri::HTML(body)
      
      logger.debug "Parsing the movie page..."
      self.rt_title = doc.css('h1.movie_title')[0].content
      self.rt_img = doc.css('.movie_tools_area img:first')[0]['src'] unless doc.css('.movie_tools_area img:first')[0].nil?
      self.rt_rating = doc.css('#tomatometer_score span:first')[0].content unless doc.css('#tomatometer_score span:first')[0].nil?

      # Nokogiri gives encoding errors when outputting the contents of the #movie_info_box
      # so we have to use these convoluted regular expressions to get the content.
      #self.rt_info = Movie::EXTRACT_MOVIE_INFO_BOX.match(body)[0] #doc.css('#movie_info_box')[0].to_s unless doc.css('#movie_info_box')[0].nil?
      inner_divs = doc.css('#movie_info_box div').length
      logger.info "MOVIE_INFO_BOX has #{inner_divs} divs"
      self.rt_info = EXTRACT_MOVIE_INFO_REGEX.call(inner_divs).match(body)[0]
      
    rescue Exception
      logger.warn "Failed loading movie #{self.tz_title} (Id: #{self.id}, Hash: #{self.tz_hash})" 
      self.loading_failed = true
      
    else
      self.loaded = true
      
    ensure
      self.save
    end

    self
  end
end
