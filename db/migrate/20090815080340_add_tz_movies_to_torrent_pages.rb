class AddTzMoviesToTorrentPages < ActiveRecord::Migration
  def self.up
    add_column :torrentz_pages, :tz_movies, :text
  end

  def self.down
    remove_column :torrentz_pages, :tz_movies
  end
end
