require 'test_helper'

class TzMovieTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Info
# Schema version: 20090816085727
#
# Table name: tz_movies
#
#  id               :integer(4)      not null, primary key
#  rt_movie_id      :integer(4)
#  last_updated     :string(255)
#  link             :string(255)
#  movie_hash       :string(255)     not null
#  normalized_title :string(255)
#  peers            :integer(4)      default(0)
#  percent          :integer(4)      default(0)
#  seeds            :integer(4)      default(0)
#  size             :integer(4)      default(0)
#  status           :string(255)
#  title            :string(255)
#  verified         :boolean(1)
#  created_at       :datetime
#  updated_at       :datetime