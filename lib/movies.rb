require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'cgi'
require 'activesupport'

CACHE_REFRESH_SECS = 300 # 5 minutes
TORRENTZ_FILE = 'torrentz.com.html'
DATA_FILE = 'movies.marshal'
JS_FILE = 'main.js'
CSS_FILE = 'main.css'
CACHE_FILE = 'cache.html'

TORRENTZ_URL = 'http://torrentz.com/verifiedP?q=movie'
ROTTEN_TOMATOES_SEARCH_URL = 'http://rottentomatoes.com/search/full_search.php?search='
ROTTEN_TOMATOES_URL = 'http://www.rottentomatoes.com'

TZ_MOVIE_LINKS_CSS = '.results dl dt a'

EXTRACT_BODY_REGEX = Regexp.new('<body[^>]*>(.*?)</body>', Regexp::IGNORECASE|Regexp::MULTILINE)
EXTRACT_HEAD_REGEX = Regexp.new('<head[^>]*>(.*?)</head>', Regexp::IGNORECASE|Regexp::MULTILINE)

module Movies
  def captureStdout
     old_stdout = $stdout
     out = StringIO.new
     $stdout = out
     begin
        yield
     ensure
        $stdout = old_stdout
     end
     out.string
  end

  def getTorrentzWebpage
    agent = WWW::Mechanize.new 
    html = agent.get(TORRENTZ_URL).body
    File.open(TORRENTZ_FILE, 'w') do |file|
      file.write(html)
    end
    html
  end
  
  def getMovie(agent, movie)
    print 'Loading movie...' + movie.keys.inspect + "\n" if DEBUG
    print ROTTEN_TOMATOES_SEARCH_URL + CGI::escape(movie['title']) + "\n" if DEBUG
    movie['loaded'] = true

    # Search for the movie and grab the first result
    print "Requesting the movie search URL...\n" if DEBUG
    result = agent.get(ROTTEN_TOMATOES_SEARCH_URL + CGI::escape(movie['title']))
    print "Parsing result of RT search...\n" if DEBUG
    doc = Nokogiri::HTML(EXTRACT_BODY_REGEX.match(result.body)[0])
    row = doc.css('#search_results_main table tbody tr:first')
    movie['rtlink'] = ROTTEN_TOMATOES_URL + row.css('td:first a')[0]['href'] unless row.css('td:first a')[0].nil?
    movie['year'] = row.css('td:last strong')[0].text.strip unless row.css('td:last strong')[0].nil?

    if movie['rtlink'].nil?
      movie['failed_loading'] = true
      print "COULDN'T FIND MOVIE!! returning\n" if DEBUG
      return movie 
    end

    # Load the movie page
    result = agent.get(movie['rtlink'])
    print "Parsing the movie page...\n" if DEBUG
    doc = Nokogiri::HTML(EXTRACT_BODY_REGEX.match(result.body)[0])
    movie['rttitle'] = doc.css('h1.movie_title')[0].content
    movie['img'] = doc.css('.movie_tools_area img:first')[0]['src'] unless doc.css('.movie_tools_area img:first')[0].nil?
    movie['rating'] = doc.css('#tomatometer_score span:first')[0].content unless doc.css('#tomatometer_score span:first')[0].nil?
    movie['infobox'] = doc.css('#movie_info_box')[0].to_s unless doc.css('#movie_info_box')[0].nil?

    return movie
  end

  def saveMovies(movies)
    File.open(DATA_FILE, 'w') do |f|
      f.write(Marshal.dump(movies))
    end

    # Try to reload it
    print "reloading the movies with marshal...\n\n" if DEBUG
    movies = Marshal.load(File.open(DATA_FILE, 'r') { |f| f.read })
  end

  def readFile(filename, default, &block)
    return default if !File.exists?(filename)

    # Read the file
    f = File.open(filename, 'r')
    content = f.read
    f.close

    # Call the block if one is given
    if !block.nil?
      yield(content)
    else
      content
    end
  end
  
end