require 'cgi'
require 'nokogiri'

#### THIS MODEL WILL BE REMOVED ####

class Movie < ActiveRecord::Base      
  



    
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