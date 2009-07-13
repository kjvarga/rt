require 'mechanize'
require 'nokogiri'
require 'lib/app'

namespace :app do
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