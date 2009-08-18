namespace :db do

  desc 'Create YAML test fixtures from data in an existing database.  
        Defaults to development database.  Set RAILS_ENV to override.'
  task 'fixtures:dump' => :environment do

    require 'fileutils'
    require 'Ya2YAML'
    
    FIXTURES_DIR = "#{RAILS_ROOT}/db/fixtures/"
    FileUtils.mkdir_p(FIXTURES_DIR)

    sql  = "SELECT * FROM %s"
    skip_tables = ["schema_info"]
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      i = "000"
      File.open(FIXTURES_DIR+"/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.ya2yaml
      end
    end
  end
    
  desc "Load seed fixtures (from db/fixtures) into the current environment's database." 
  task :seed => :environment do
    require 'active_record/fixtures'
    Dir.glob(RAILS_ROOT + '/db/fixtures/*.yml').each do |file|
      Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
    end
  end
    
  desc "Migrate rottentomatoes and torrentz movies to separate tables."
  task :separate_movies => :environment do
    
    TZ_MOVIE_MAP = { 
      :status => :status,
      :tz_hash => :movie_hash,
      :tz_link => :link,
      :tz_title => :title,
      :normalized_tz_title => :normalized_title
    }
    RT_MOVIE_MAP = {
      :rt_img => :img,
      :rt_info => :info,
      :rt_link => :link,
      :rt_rating => :rating,
      :rt_title => :title,
      :year => :year,
      :normalized_rt_title => :normalized_title
    }
    ActiveRecord::Base.silence do
      Movie.find_in_batches(:batch_size => 500) do |movies|
        movies.each do |movie|
          
          # We need to make sure we don't include duplicate RT movies here
          # Also don't create RT movies if the movie status is failed
          rt = RtMovie.find_by_link(movie.rt_link)
          if movie.is_loaded? and rt.nil?
            rt = RtMovie.new
            RT_MOVIE_MAP.each_pair do |left, right|
              rt.send(right.to_s + '=', movie.send(left)) 
            end
            
            # Extract the genre and remove the celebrity links?
            rt.save!
          end
          
          # We should be ok creating the equivalent torrentz movie record
          tz = TzMovie.find_or_initialize_by_movie_hash(movie.tz_hash)
          TZ_MOVIE_MAP.each_pair do |left, right|
            tz.send(right.to_s + '=', movie.send(left)) 
          end
          tz.rt_movie = rt unless rt.nil?
          tz.percent = rt.nil? ? 0 : movie.fuzzy_compare(rt.title)
          tz.save! if tz.changed?
        end
      end
    end
  end
  
  desc "Extract the movie hashes from each torrent page and save the array in the table."
  task :save_movie_hashes_on_torrentz_pages => :environment do
    TorrentzPage.find_in_batches(:batch_size => 500) do |pages|
      pages.each do |page|
        page.extractMovies
        page.save
      end
    end
  end
end