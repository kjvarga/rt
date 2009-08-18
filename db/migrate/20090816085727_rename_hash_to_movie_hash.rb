class RenameHashToMovieHash < ActiveRecord::Migration
  def self.up
    rename_column :tz_movies, :hash, :movie_hash
    remove_index :tz_movies, :hash
    add_index :tz_movies, :movie_hash
  end

  def self.down
    rename_column :tz_movies, :movie_hash, :hash
    remove_index :tz_movies, :movie_hash
    add_index :tz_movies, :hash    
  end
end
