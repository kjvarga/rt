require 'test_helper'
require 'rubygems'
require 'mechanize'
require 'nokogiri'

class MovieTest < ActiveSupport::TestCase

  
  test "loading movie information" do

    movies = Movie.find(:all)
    movies.each do |movie|
      movie.lookupMovie
      assert_not_nil movie.year
      assert_not_nil movie.rt_rating
      assert_not_nil movie.rt_title
      assert_not_nil movie.rt_info
      assert_not_nil movie.rt_img
      assert_not_nil movie.rt_link
    end
  end
end
