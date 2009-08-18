class MoviesController < ApplicationController
  
  RETRY_AFTER_FAILED_ATTEMPTS = 5
  
  # Get ratings for a number of movies identified by their hash
  def ratings
    movies = Movie.loaded_or_failed_movies.find_all_by_tz_hash(
        params[:tz_hash], 
        :select => 'id, tz_hash, rt_rating, rt_title, status')
    movies_hashes = movies.map do |movie| 
      { :id => movie.id,
        :tz_hash => movie.tz_hash,
        :rt_rating => movie.rt_rating,
        :path => "/movies/show/#{movie.to_param}",
        :status => movie.status }
    end
    
    # If no movies have been loaded after 5 calls, something must
    # be wrong, so force a load.
    if movies.length == 0
      if session['failed_movie_requests'].nil?
        session['failed_movie_requests'] = 1
      end
      session['failed_movie_requests'] += 1
      logger.info "#{session['failed_movie_requests']} failed attempt to load movies for url #{params[:url]}"
      if session['failed_movie_requests'] >= MoviesController::RETRY_AFTER_FAILED_ATTEMPTS
        url = params[:url].sub('rottentorrentz.local', 'torrentz.com')
        logger.info "Third failed attempt to load movies!  Calling rake for url #{params[:url]} (tz page id #{session[:torrentz_page_id]})"
        App::call_rake('tz:load_movies', :id => session[:torrentz_page_id])
        session['failed_movie_requests'] = 0
      end
    end
    
    respond_to do |fmt|
      fmt.json { render :json => movies_hashes.to_json }
    end
  end
  
  def show
    unless read_fragment(
        { :controller => 'movies', :action => 'show', :id => params[:id], :xml_request => request.xhr? }, 
        { :expires_in => 1.day })
        
      @movie = Movie.find_by_id(params[:id])
      @keywords = @title = @movie.rt_title
      if request.xhr?
        render @movie, :layout => false 
      else 
        render
      end
    end
  end
end
