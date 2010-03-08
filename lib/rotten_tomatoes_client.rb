class RottenTomatoesClient

  THRESHOLD = 50  # 50% threshold on matching trigrams

  def title_matches?
    if conservative
      title_one = conservative_normalize_title(title_one)
    else
      title_one = Movie::normalize_words(title_one)
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
    
    if self.status == Movie::LOADED
      logger.warn "This movie has already been loaded!"
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
      rt_info = Movie::EXTRACT_MOVIE_INFO_REGEX.call(inner_divs).match(body)[0]
      rt_info.gsub!(Movie::EXTRACT_SCRIPT_REGEX, '')
      self.rt_info = rt_info
      
    rescue Exception
      logger.warn "Failed loading movie #{self.tz_title} (Id: #{self.id}, Hash: #{self.tz_hash})" 
      self.status = Movie::FAILED
      
    else
      self.status = Movie::LOADED
      
    ensure
      self.save
    end

    self
  end  
end