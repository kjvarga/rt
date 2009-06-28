require 'test_helper'

class TorrentzPageTest < ActiveSupport::TestCase

  test "Download and cache torrentz webpages" do
    tz = @empty_html
    assert_nil tz.html
    
    # Get it for the first time, should load html
    logger.debug "Loading URL #{tz.url} for the first time..."
    first = TorrentzPage.findOrCreate(tz.url)
    assert_equal tz, first
    assert_operator first.updated_at, :>, 5.minutes.ago
    assert_not_nil first.html
    
    # Get it again, shouldn't be modified
    logger.debug "Loading URL #{tz.url} for the second time..."
    second = TorrentzPage.findOrCreate(tz.url)
    assert_equal tz, second
    assert_equal second.updated_at.to_i, first.updated_at.to_i
  end
  
  test "Update old cached versions of the torrentz webpages" do
    logger.debug @reload_from_cache.inspect

    tz = @reload_from_cache
    six_mins = tz.updated_at
    five_mins = (Time.zone.now - 5.minutes)
    logger.debug six_mins.inspect
    logger.debug five_mins.inspect
    assert_operator six_mins, :<, five_mins
    assert_equal 'loaded', tz.html
    first = TorrentzPage.findOrCreate(tz.url)
    assert_equal tz, first
    #assert_operator first.updated_at, :>, tz.updated_at, "record should have been updated"
    #assert_not_equal 'loaded', first.html
  end
  
  test "Process the torrentz webpages" do

    # Process elements with src=""
    html = @link_processing_src.processPage(@link_processing_src.html)
    assert_equal @link_processing_src_result.html, html, "SRC elements should be prepended with the Torrentz.com URL"

    # Process links with href=""
    html = @link_processing_href.processPage(@link_processing_href.html)
    assert_equal @link_processing_href_result.html, html, "Some HREF elements should be prepended with the Torrentz.com URL while others should pass through"
    
    # Remove iframes
    html = @remove_iframe.processPage(@remove_iframe.html)
    assert_not_nil @remove_iframe.html
    assert_equal '', html.strip, "IFRAMES should be removed"
    
    # Add our javascript include to the head
    html = @process_head.processPage(@process_head.html.strip)
    assert_equal @process_head_result.html, html.strip, "Append our JavaScript include to the contents of HEAD"
  end
  
  test "Extract movies from the html" do

    tz = TorrentzPage.findOrCreate(@order_by_name.url)
    movies = tz.extractMovies
    assert_equal 51, movies.length
    
    # Test saving the movies, it should not overwrite the existing ones
    Movie.delete_all
    assert_equal 0, Movie.count, "There should be no movie records"
    Movie.saveMoviesFromArray(movies)
    assert_equal movies.length, Movie.count, "Now we have a bunch of movies"
    first = Movie.find :first
    first.rt_rating = 99
    assert first.save
    Movie.saveMoviesFromArray(movies)
    first = Movie.find :first
    assert_equal 99, first.rt_rating
  end
end
