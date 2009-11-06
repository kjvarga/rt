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
      assert_no_match Movie::EXTRACT_SCRIPT_REGEX, movie.rt_info
    end
  end
end

# == Schema Info
# Schema version: 20090816085727
#
# Table name: movies
#
#  id                  :integer(4)      not null, primary key
#  normalized_rt_title :string(255)
#  normalized_tz_title :string(255)
#  rt_img              :string(255)
#  rt_info             :text
#  rt_link             :string(255)
#  rt_rating           :integer(4)      default(0)
#  rt_title            :string(255)
#  status              :string(255)
#  tz_hash             :string(255)
#  tz_link             :string(255)
#  tz_title            :string(255)
#  year                :integer(4)
#  created_at          :datetime
#  updated_at          :datetime