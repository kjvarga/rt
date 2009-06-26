class CreateMovies < ActiveRecord::Migration
  def self.up
    create_table :movies do |t|
      t.string :tz_link
      t.string :rt_link
      t.integer :year
      t.boolean :loaded
      t.boolean :loading_failed
      t.string :rt_img
      t.integer :rt_rating
      t.text :rt_info
      t.string :rt_title
      t.string :tz_title
      t.string :tz_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :movies
  end
end
