class MoviesController < ApplicationController
  
  # Get ratings for a number of movies identified by their hash
  def ratings
    movies = Movie.loaded_movies.find_all_by_tz_hash(
        params[:tz_hash], 
        :select => 'id, tz_hash, rt_rating, rt_title')
    movies_hashes = movies.map do |movie| 
      { :id => movie.id,
        :tz_hash => movie.tz_hash,
        :rt_rating => movie.rt_rating,
        :path => "/movies/show/#{movie.to_param}" }
    end
    respond_to do |fmt|
      fmt.json { render :json => movies_hashes.to_json }
    end
  end
  
  def show
    @movie = Movie.find_by_id(params[:id])
    render @movie
  end
end
