namespace :tz do

  desc "Update a torrentz.com URL"
  task :update_page => :environment do
    unless ENV.include?("ID") && ENV['ID'].to_i != 0
      raise "torrentz page ID is missing!" 
    end
    tzpage = TorrentzPage.find(ENV['ID'].to_i)
    tzpage.downloadUrl
    tzpage.save
    
    # process the movies
    extractAndLoadMovies(tzpage)
  end
  
  desc "Extract the movies from a torrentz.com page and start loading them"
  task :load_movies => :environment do
    unless ENV.include?("ID") && ENV['ID'].to_i != 0
      raise "torrentz page ID is missing!" 
    end
    
    tzpage = TorrentzPage.find(ENV['ID'].to_i)
    extractAndLoadMovies(tzpage)
  end  
  
  def extractAndLoadMovies(tzpage)
    tzpage.extractMovies
    Movie.saveMoviesFromArray(tzpage.movies)
  end  
end
