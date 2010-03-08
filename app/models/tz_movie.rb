require 'cgi'

class TzMovie < ActiveRecord::Base
  belongs_to :rt_movie
  
  validates_uniqueness_of :movie_hash
  validates_presence_of :title, :link, :status
  
  named_scope :new_movies, :conditions => { :status => nil }
  named_scope :loading_movies, :conditions => { :status => TzMovie::LOADING }
  named_scope :failed_movies, :conditions => { :status => TzMovie::FAILED }
  named_scope :loaded_movies, :conditions => { :status => TzMovie::LOADED }
  named_scope :loaded_or_failed_movies, :conditions => { :status => [TzMovie::LOADED, TzMovie::FAILED] }
    
  JUNK_WORDS = %w{xvid dvdrip com org rarbg ac3 german avi x264 pack btarena collection tracker 720p mvgroup bluray limited mega movie www 1080p axxo pal dvd eng vomit divx movies hdtv domino mnvv2 fxg dvdscr dvdr complete channel zektorm cam komplett hd2dvd dts filme devise info moh unrated tinq91 rip french tfe dvd9 proper audio net bestdivx wars zeichentrickfilm internal torrent telesync stv screener brrip}
  LOADING = 'loading'
  LOADED = 'loaded'
  FAILED = 'failed'
  
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
  
  # Normalize the title by removing punctuation, HTML tags and common words.
  # We use this title to search on because it contains far less "noise".
  def normalized_title
    return normalized_title if normalized_title.present?
    return title unless title.present?
    
    title = CGI::unescapeHTML(title) # convert &quot; etc to regular characters
    title = ActionController::Base.helpers.strip_tags(title) # remove <b> tages etc

    # Lowercase, strip punctuation
    title = TrigramSearch.normalize_words(title)
    
    # Remove junk words.  Do this after stripping html tags
    words = title.split(/\s+/)
    words.delete_if { |word| TzMovie::JUNK_WORDS.include?(word) }  
    title = words.join(' ')
    
    normalized_title = title
  end
end

# == Schema Info
# Schema version: 20100308074028
#
# Table name: tz_movies
#
#  id               :integer         not null, primary key
#  rt_movie_id      :integer
#  last_updated     :string(255)
#  link             :string(255)
#  movie_hash       :string(255)     not null
#  normalized_title :string(255)
#  peers            :integer         default(0)
#  percent          :integer         default(0)
#  seeds            :integer         default(0)
#  size             :integer         default(0)
#  status           :string(255)
#  title            :string(255)
#  verified         :boolean
#  created_at       :datetime
#  updated_at       :datetime