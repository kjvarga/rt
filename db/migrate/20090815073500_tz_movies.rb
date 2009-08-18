class TzMovies < ActiveRecord::Migration
  def self.up
    create_table :tz_movies do |t|
      t.string :hash, :null => false
      t.string :link
      t.string :title
      t.string :normalized_title
      t.string :status
      t.integer :rt_movie_id
      t.string :last_updated
      t.boolean :verified
      t.integer :size, :default => 0
      t.integer :seeds, :default => 0
      t.integer :peers, :default => 0
      t.timestamps
    end

    add_index :tz_movies, :hash, :unique => true
    add_index :tz_movies, :status
  end

  def self.down
    remove_index :tz_movies, :hash
    remove_index :tz_movies, :status
        
    drop_table :tz_movies
  end
end
