require 'mechanize'
require 'nokogiri'
require 'lib/app'

namespace :app do
  desc "Regenerate the SASS stylesheets."
  task :update_sass => :environment do
    Sass::Plugin.update_stylesheets
  end
  
  desc 'Update the sitemap and symlink it to the public/system folder.
  
        Add the following to your cron file to regenerate the sitemap file twice a week:
          0 0 * * 1,5 nice rake -f ~/sites/rottentorrentz/current/Rakefile app:update_sitemap_and_symlink --trace 2>&1 >> ~/sites/rottentorrentz/current/log/rake.log'
  task :update_sitemap_and_symlink do
    
    environment = ENV['RAILS_ENV'] || 'production'
    pub = File.join(RAILS_ROOT, 'public')
    sys = File.join(RAILS_ROOT, 'public', 'system', '')
    
    # If generation fails, copy from system back to public
    if system("nice rake sitemap:refresh -f #{RAILS_ROOT}/Rakefile RAILS_ENV=#{environment} --trace 2>&1 >> #{RAILS_ROOT}/log/rake.log")
      system("cp -f #{File.join(pub, 'sitemap')}* #{sys}")
    else
      system("cp -f #{File.join(sys, 'sitemap')}* #{pub}")
    end
  end

  desc "Touch the home page and send an email if it doesn't return a 200 status code."
  task :ping => :environment do
    uri = ENV['TEST'] == 'true' ? Rails.root + '/application/test_mailer' : URI.parse(SiteDefaults::URL)
    res = Net::HTTP.get_response(uri)
    return if res.code_type.superclass == Net::HTTPSuccess
    
    # Request failed for some reason, send an email
    Notifier.deliver_site_error(uri, res)
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
      
      puts "Touching #{SiteDefaults::URL + url}"
      begin
        doc = Nokogiri::HTML(agent.get(SiteDefaults::URL + url).body)
        
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