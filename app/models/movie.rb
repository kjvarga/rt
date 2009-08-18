require 'cgi'
require 'nokogiri'

class Movie < ActiveRecord::Base      
  JUNK_WORDS = %w{xvid dvdrip com org rarbg ac3 german avi x264 pack btarena collection tracker 720p mvgroup bluray limited mega movie www 1080p axxo pal dvd eng vomit divx movies hdtv domino mnvv2 fxg dvdscr dvdr complete channel zektorm cam komplett hd2dvd dts filme devise info moh unrated tinq91 rip french tfe dvd9 proper audio net bestdivx wars zeichentrickfilm internal torrent telesync stv screener brrip}
  THRESHOLD = 50  # 50% threshold on matching trigrams
  
  LOADING = 'loading'
  LOADED = 'loaded'
  FAILED = 'failed'
  
  before_save :normalize_titles
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

  #
  # Dynamically add status discovery methods: is_loaded?, is_failed? etc
  #
  def method_missing(method_id, *arguments)
    if match = /is_(\w+)\?/.match(method_id.to_s)
      self.status == match[1]
    else
      super
    end
  end
    
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
      #movie.lock!
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
      #movie.lock!
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
  
  # 
  # Trigrams search methods
  #
  
  # Return a degree of match between a RottenTomatoes movie title 
  # and movie's title.
  #
  # @param conservative true/false/"auto", default false
  def fuzzy_compare(search_words, conservative=false)
    return 0 if search_words.blank?
    
    if conservative
      search_words = Movie::conservative_normalize_rt_title(search_words)
    else
      search_words = Movie::normalize_words(search_words)
    end
    search_trigrams = Movie::trigrams(search_words, true)     
    
    title_words = self.normalized_tz_title
    title_trigrams = Movie::trigrams(title_words, true)     

    #puts "Original title: #{rt_title}"
    #puts "Normalized title: #{title_words}"
    #puts "Search words: #{search_words}"
    
    # Calculate the percentage of search trigrams matched in the movie title
    count = 0.0
    search_trigrams.each do |trigram|
      count += 1 if title_trigrams.include?(trigram)
    end
    percent = search_trigrams.empty? ? 0 : ((count / search_trigrams.length) * 100).to_i
    #puts "Percent match: #{percent}"
    percent
  end
  
  # Normalize the tz title as well as remove common words
  # This method uses actionview helpers so it needs the Rails environment!
  def normalized_tz_title
    return self[:normalized_tz_title] if attribute_present?(:normalized_tz_title) or !attribute_present?(:tz_title)
    
    title_words = self.tz_title
    
    require 'cgi'
    title_words = CGI::unescapeHTML(title_words) # convert &quot; etc to regular characters
    title_words = ActionController::Base.helpers.strip_tags(title_words) # remove <b> tages etc

    # Lowercase, strip punctuation
    title_words = Movie::normalize_words(title_words)
    
    # Remove junk words.  Do this after stripping html tags
    title_words = title_words.split(/\s+/)
    title_words.delete_if { |word| Movie::JUNK_WORDS.include?(word) }  
    title_words = title_words.join(' ')
    
    return self[:normalized_tz_title] = title_words
  end
    
  private
    # Touch the titles to make sure they're set
    def normalize_titles
      normalized_rt_title
      normalized_tz_title
      self
    end
    
    # Normalize the rottentomatoes title
    #
    # Remove leading 'the', 'a' and 'and' from the title because the TZ title often doesn't
    # include these words.
    # Remove the year from titles that are just a few words because often the TZ
    # movie year is incorrect and this throws off the match for short titles.
    # Change '&' to 'and'.
    def self.conservative_normalize_rt_title(title)
      title = title.strip.downcase.gsub(/[^\w\d ]/, '')
      title.gsub!(/^((the|a|and)\b)/, '')
      title.gsub!(/\s\d{4}$/, '')  # the year should be at the end
      title.gsub!(/\s&\s/, ' and ')
      title
    end
    
    # Normalize a search term by downcasing it, removing punctuation and multiple spaces
    def self.normalize_words(word)
      return word.strip.downcase.gsub(/[^\w\d ]/, '')
    end

    # Return the trigrams that form *word*, optionally appending a space on the end to
    # weight a match on the end of the word.  A space is always added to the beginning.
    def self.trigrams(word, weighted_end=false)
      word = ' ' + word + (weighted_end ? ' ' : '')
      return (0..word.length-3).collect { |idx| word[idx,3] }
    end
end

# == Schema Info
# Schema version: 20090815080340
#
# Table name: movies
#
#  id                  :integer         not null, primary key
#  normalized_rt_title :string(255)
#  normalized_tz_title :string(255)
#  rt_img              :string(255)
#  rt_info             :text
#  rt_link             :string(255)
#  rt_rating           :integer         default(0)
#  rt_title            :string(255)
#  status              :string(255)
#  tz_hash             :string(255)
#  tz_link             :string(255)
#  tz_title            :string(255)
#  year                :integer
#  created_at          :datetime
#  updated_at          :datetime