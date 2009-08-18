require 'test_helper'

class TzMovieTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Info
# Schema version: 20090815080340
#
# Table name: tz_movies
#
#  id               :integer         not null, primary key
#  rt_movie_id      :integer
#  hash             :string(255)     not null
#  last_updated     :string(255)
#  link             :string(255)
#  normalized_title :string(255)
#  peers            :integer         default(0)
#  seeds            :integer         default(0)
#  size             :integer         default(0)
#  status           :string(255)
#  title            :string(255)
#  verified         :boolean
#  created_at       :datetime
#  updated_at       :datetime