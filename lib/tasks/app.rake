require 'mechanize'
require 'nokogiri'
require 'lib/app'

namespace :app do
  desc "Regenerate the SASS stylesheets."
  task :update_sass => :environment do
    Sass::Plugin.update_stylesheets
  end
  
  desc "Update the sitemap and symlink it to the public/system folder."
  task :update_sitemap_and_symlink do
    
    environment = ENV['RAILS_ENV'] || 'production'
    rakefile = File.join(RAILS_ROOT, 'Rakefile')
    pub = File.join(RAILS_ROOT, 'public')
    sys = File.join(RAILS_ROOT, 'public', 'system', '')
    
    # If generation fails, copy from system back to public
    if system("nice rake sitemap:refresh -f #{rakefile} RAILS_ENV=#{environment}")
      system("cp -f #{File.join(pub, 'sitemap')}* #{sys}")
    else
      system("cp -f #{File.join(sys, 'sitemap')}* #{pub}")
    end
  end
  
  desc "Translate the character encoding of RottenTomatoes info to unicode from CP1252"
  task :translate_to_unicode => :environment do
    Movie.find_in_batches(:batch_size => 1000) do |movies|
      movies.each do |movie|
        next if movie.rt_info.nil?
        movie.save!
        movie.rt_info = movie.rt_info + ' '
        movie.save!
      end
    end
  end
  
  desc "Touch all links on all pages."
  task :touch_links do
    
    url = '/application/torrentz'
    links = {}
    agent = WWW::Mechanize.new 
    
    # While we have a link to process
    while !url.nil?
      
      puts "Touching #{App::SITE_URL + url}"
      begin
        doc = Nokogiri::HTML(agent.get(App::SITE_URL + url).body)
        
        # mark it as processed
        links[url] = true
        doc.css('div.results a').each do |link|
          href = link['href']

          # If we don't have it already, add it for later processing
          if href.match(/^\//) && links[href].nil?
            links[href] = nil
          end
        end
        
        # Give it time to process
        sleep 60
        
      rescue Exception
        puts '>> Failed!'
        
        # mark it as processed
        links[url] = true
      end  
    
      # Get the next link to process
      url = nil
      links.each do |key, value|
        if links[key].nil?
          url = key
          break
        end
      end
      
      #puts links.keys.join("\n")
      #puts "URL: #{url}"
      #break
    end
    puts "Done!"
  end
end