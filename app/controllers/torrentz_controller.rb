class TorrentzController < ApplicationController
  def index
    
    # Figure out the url to show
    if params[:q].nil? or params[:searchOrVerified].nil?
      url = TorrentzPage::POPULAR_URL
    else
      p = params[:p] || 0
      url = "#{TorrentzPage::SITE_URL}#{params[:searchOrVerified]}?q=#{params[:q]}&p=#{p}"
    end
    
    # Check the cache
    unless read_fragment(
        { :url => url }, 
        { :expires_in => 5.minutes })
      
      # Rerender the page
      @torrent_page = TorrentzPage.findOrCreate(url)
      session[:torrentz_page_id] = @torrent_page.id

      if @torrent_page.updated_at <= 5.minutes.ago
        App::call_rake('tz:update_page', :id => @torrent_page.id)
      elsif !@torrent_page.movies.nil?
        App::call_rake('tz:load_movies', :id => @torrent_page.id)
      end
      
      movies = Movie.loaded_or_failed_movies.find_all_by_tz_hash(
          @torrent_page.tz_movies, :select => 'id, tz_hash, rt_rating, rt_title, status')
      @movies_hash = {}    
      movies.each do |movie| 
        @movies_hash[movie.tz_hash] = { 
          :id => movie.id,
          :tz_hash => movie.tz_hash,
          :rt_rating => movie.rt_rating,
          :path => "/movies/show/#{movie.to_param}",
          :status => movie.status }
      end
    end
  end
end