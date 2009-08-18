class RtMovie < ActiveRecord::Migration
  def self.up
    create_table :rt_movies do |t|
      t.string :img
      t.string :link
      t.integer :year
      t.text :info
      t.integer :rating, :default => 0
      t.string :title
      t.string :normalized_title
      t.string :genre
      t.timestamps
    end
    
    add_index :rt_movies, :link, :unique => true
    add_index :rt_movies, :genre
    add_index :rt_movies, :rating
    add_index :rt_movies, :year
  end

  def self.down
    remove_index :rt_movies, :link
    remove_index :rt_movies, :genre
    remove_index :rt_movies, :rating
    remove_index :rt_movies, :year
    
    drop_table :rt_movies
  end
end
