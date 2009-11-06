require 'nokogiri'

namespace :tz do

  desc "Update a torrentz.com URL"
  task :update_page => :environment do
    unless ENV.include?("ID") && ENV['ID'].to_i != 0
      raise "usage: rake tz:update_page ID=torrentz_page_id" 
    end
    tzpage = TorrentzPage.find(ENV['ID'].to_i)
    tzpage.downloadUrl
    tzpage.save
    
    # Expire the fragment cache for this URL
    ActionController::Base.new.expire_fragment( :url => tzpage.url )
    
    # process the movies
    extractAndLoadMovies(tzpage)
  end
  
  desc "Extract the movies from a torrentz.com page and start loading them"
  task :load_movies => :environment do
    unless ENV.include?("ID") && ENV['ID'].to_i != 0
      raise "usage: rake tz:load_movies ID=torrentz_page_id"
    end
    
    tzpage = TorrentzPage.find(ENV['ID'].to_i)
    extractAndLoadMovies(tzpage)
  end
  
  desc "Extract the results div from all torrentz pages, discarding everything else."
  task :extract_results_div => :environment do
    TorrentzPage.transaction do
      tzpages = TorrentzPage.find :all
      tzpages.each do |tz|
        tz.processPage
        tz.save!
      end 
    end
  end

  def extractAndLoadMovies(tzpage)
    tzpage.extractMovies
    Movie.saveMoviesFromArray(tzpage.movies)
  end 
end
