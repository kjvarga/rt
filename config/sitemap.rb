# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://rottentorrentz.com/"

SitemapGenerator::Sitemap.add_links do |sitemap|
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: sitemap.add path, options
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly', 
  #           :lastmod => Time.now, :host => default_host

  
  # Examples:
  
  # add '/articles'
  #sitemap.add articles_path, :priority => 0.7, :changefreq => 'weekly'

  # add torrentz pages
  TorrentzPage.find_in_batches(:batch_size => 1000) do |torrentzpages|
    torrentzpages.each do |tz|
      sitemap.add tz.localUrl(SitemapGenerator::Sitemap.default_host), 
          :lastmod => tz.updated_at, :changefreq => 'daily'
    end
  end

  # add movies
  Movie.loaded_movies.find_in_batches(:batch_size => 1000) do |movies|
    movies.each do |movie|
      sitemap.add "/movies/show/#{movie.to_param}", :lastmod => movie.updated_at, 
          :changefreq => 'weekly'
    end
  end
end
