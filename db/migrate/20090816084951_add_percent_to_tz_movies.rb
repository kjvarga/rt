class AddPercentToTzMovies < ActiveRecord::Migration
  def self.up
    add_column :tz_movies, :percent, :integer, :default => 0
    add_index :tz_movies, :percent
  end

  def self.down
    remove_column :tz_movies, :percent
    remove_index :tz_movies, :percent
  end
end
