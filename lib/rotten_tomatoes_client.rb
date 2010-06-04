require 'rubygems'
require 'nokogiri'
require 'open-uri'

MovieResult = Struct.new(:link, :title, :year) do
  def initialize(row)
    anchor = row.at_css('td:first a')
    link = anchor['href']
    link = RottenTomatoesClient::ROTTEN_TOMATOES_URL + link unless link =~ RottenTomatoesClient::ROTTEN_TOMATOES_URL
    title = anchor.text.strip
    year = row.at_css('td:last strong')
    year = year.text.strip unless year.nil?    
  end
end

class RottenTomatoesClient
  
  THRESHOLD = 50  # 50% of trigrams from the search title must match
  HOST = 'http://www.rottentomatoes.com'
  
  EXTRACT_BODY_REGEX = /<body[^>]*>(.*?)<\/body>/mi
  EXTRACT_SCRIPT_REGEX = /(<script[^>]*>.*?<\/script>)/mi
  EXTRACT_MOVIE_INFO_REGEX = lambda { |inner_divs| 
    Regexp.new('(<div id="movie_info_box"[^>]*>(.*?</div>){'+inner_divs.to_s+'})', 
        Regexp::IGNORECASE|Regexp::MULTILINE) 
  }
  
  # Return a boolean indicating whether the title matches 
  def title_matches?(title)
    if conservative
      title_one = TrigramSearch.conservative_normalize_title(title_one)
    else
      
    end
    search_title = TrigramSearch.normalize_words(title_one)
  
  end  

  # Search for a title on RottenTomatoes and find the best match in the search
  # results.  The title is normalized.
  def self.search(title)
    url = RottenTomatoesClient::HOST + '/search/full_search.php?search=' + CGI::escape(title)
    doc = Nokogiri::HTML(u(open(url))) # convert to unicode
    
    rows = doc.css('#search_results_main table')[0].css('tbody tr')
    results = rows.collect do |row|
      MovieResult.new(row)
    end
    
    # Find the best match
    results.each do |movie|
      
    end
  end
  
  #
  # Lookup a movie on RT and save its info
  #
  def lookupMovie
    
    # Validation
    if self.tz_title.nil?
      logger.warn "This movie doesn't have a title!"
      return
    end
    
    if self.status == TzMovie::LOADED
      logger.warn "This movie has already been loaded!"
      return
    end
    
    logger.debug 'Loading movie...' + self.inspect
    begin
      # Search for the movie and grab the first result
      logger.debug "Requesting the movie search URL..." 
      result = self.class.agent.get(Movie::ROTTEN_TOMATOES_SEARCH_URL + CGI::escape(self.tz_title))
      logger.debug "Parsing result of RT search..." 
      doc = Nokogiri::HTML(TzMovie::EXTRACT_BODY_REGEX.match(result.body)[0])
      row = doc.css('#search_results_main table tbody tr:first')
      self.rt_link = TzMovie::ROTTEN_TOMATOES_URL + row.css('td:first a')[0]['href']
      self.year = row.css('td:last strong')[0].text.strip unless row.css('td:last strong')[0].nil?

      # Load the movie page
      result = self.class.agent.get(self.rt_link)
      body = TzMovie::EXTRACT_BODY_REGEX.match(result.body)[0]
      doc = Nokogiri::HTML(body)
      
      logger.debug "Parsing the movie page..."
      self.rt_title = doc.css('h1.movie_title')[0].content
      self.rt_img = doc.css('.movie_tools_area img:first')[0]['src'] unless doc.css('.movie_tools_area img:first')[0].nil?
      self.rt_rating = doc.css('#tomatometer_score span:first')[0].content unless doc.css('#tomatometer_score span:first')[0].nil?

      # Nokogiri gives encoding errors when outputting the contents of the #movie_info_box
      # so we have to use these convoluted regular expressions to get the content.
      #self.rt_info = TzMovie::EXTRACT_MOVIE_INFO_BOX.match(body)[0] #doc.css('#movie_info_box')[0].to_s unless doc.css('#movie_info_box')[0].nil?
      inner_divs = doc.css('#movie_info_box div').length
      rt_info = TzMovie::EXTRACT_MOVIE_INFO_REGEX.call(inner_divs).match(body)[0]
      rt_info.gsub!(TzMovie::EXTRACT_SCRIPT_REGEX, '')
      self.rt_info = rt_info
      
    rescue Exception
      logger.warn "Failed loading movie #{self.tz_title} (Id: #{self.id}, Hash: #{self.tz_hash})" 
      self.status = TzMovie::FAILED
      
    else
      self.status = TzMovie::LOADED
      
    ensure
      self.save
    end

    self
  end  
end