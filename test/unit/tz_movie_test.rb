require 'test_helper'

class TzMovieTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Info
# Schema version: 20100308074028
#
# Table name: tz_movies
#
#  id               :integer         not null, primary key
#  rt_movie_id      :integer
#  last_updated     :string(255)
#  link             :string(255)
#  movie_hash       :string(255)     not null
#  normalized_title :string(255)
#  peers            :integer         default(0)
#  percent          :integer         default(0)
#  seeds            :integer         default(0)
#  size             :integer         default(0)
#  status           :string(255)
#  title            :string(255)
#  verified         :boolean
#  created_at       :datetime
#  updated_at       :datetime