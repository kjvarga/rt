class AlterMovieRtRatingAddDefault < ActiveRecord::Migration
  def self.up
    change_column_default :movies, :rt_rating, 0
  end

  def self.down
  end
end
