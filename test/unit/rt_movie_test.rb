require 'test_helper'

class RtMovieTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Info
# Schema version: 20090816085727
#
# Table name: rt_movies
#
#  id               :integer(4)      not null, primary key
#  genre            :string(255)
#  img              :string(255)
#  info             :text
#  link             :string(255)
#  normalized_title :string(255)
#  rating           :integer(4)      default(0)
#  title            :string(255)
#  year             :integer(4)
#  created_at       :datetime
#  updated_at       :datetime