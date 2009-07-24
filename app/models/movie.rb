# == Schema Information
# Schema version: 20090705150709
#
# Table name: movies
#
#  id         :integer         not null, primary key
#  tz_link    :string(255)
#  rt_link    :string(255)
#  year       :integer
#  rt_img     :string(255)
#  rt_rating  :integer
#  rt_info    :text
#  rt_title   :string(255)
#  tz_title   :string(255)
#  tz_hash    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  status     :string(255)
#

require 'cgi'
require 'nokogiri'

class Movie < ActiveRecord::Base
  
  LOADING = 'loading'
  LOADED = 'loaded'
  FAILED = 'failed'
  
  validates_uniqueness_of :tz_hash
  named_scope :new_movies, :conditions => { :status => nil }
  named_scope :loading_movies, :conditions => { :status => Movie::LOADING }
  named_scope :failed_movies, :conditions => { :status => Movie::FAILED }
  named_scope :loaded_movies, :conditions => { :status => Movie::LOADED }
  named_scope :loaded_or_failed_movies, :conditions => { :status => [Movie::LOADED, Movie::FAILED] }
  
  to_unicode :rt_info
  to_unicode :rt_title
  
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
  EXTRACT_BODY_REGEX = /<body[^>]*>(.*?)<\/body>/mi
  EXTRACT_SCRIPT_REGEX = /(<script[^>]*>.*?<\/script>)/mi
  EXTRACT_MOVIE_INFO_REGEX = lambda { |inner_divs| 
    Regexp.new('(<div id="movie_info_box"[^>]*>(.*?</div>){'+inner_divs.to_s+'})', 
        Regexp::IGNORECASE|Regexp::MULTILINE) 
  }
  
  # Create movie instances for movies that don't yet exist in the db
  # from an array of [link, hash, title] tuples, and then load them.
  # Also reloads failed movies.
  def self.saveMoviesFromArray(movies)
    movie_objs = []
    transaction do
      movies.each do |movie|
        hash = movie[1].strip
        m = Movie.find_or_create_by_tz_hash(
          :tz_hash => hash,
          :tz_link => movie[0].strip, 
          :tz_title => movie[2].strip
        ) # the save should fail if it already exists
        #m ||= Movie.find_by_tz_hash(hash)
        movie_objs.push(m)
      end
    end
    logger.debug "saveMoviesFromArray: STARTING processing #{movie_objs.size} movies"
    movie_objs.each do |movie|
      movie.lock!
      logger.debug "saveMoviesFromArray: MOVIE #{movie.id} STATUS IS #{movie.status} TITLE IS #{movie.tz_title}"
      unless movie.status.nil? \
          or movie.status == Movie::FAILED \
          or (movie.status == Movie::LOADING and movie.updated_at < 10.minutes.ago)
        next
      end
      logger.debug "saveMoviesFromArray: LOADING MOVIE #{movie.id}"
      movie.status = Movie::LOADING
      movie.save
      movie.lookupMovie
    end
    logger.debug "saveMoviesFromArray: FINISHED processing #{movie_objs.length} movies"
  end
  
  # Download movies that have not been loaded yet
  def self.loadNewMovies
    movies = Movie.new_movies.find(:all, :order => :created_at)
    movies.each do |movie|
      movie.lock!
      break unless movie.status.nil?
      movie.status = Movie::LOADING
      movie.save
      movie.lookupMovie
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
  
  # Use descriptive URLs
  def to_param
    title = self.rt_title || 'loading-failed'
    "#{self.id}/#{title.to_safe_uri}"
  end
end
