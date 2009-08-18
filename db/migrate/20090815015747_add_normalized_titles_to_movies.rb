class AddNormalizedTitlesToMovies < ActiveRecord::Migration
  def self.up
    add_column :movies, :normalized_tz_title, :string
    add_column :movies, :normalized_rt_title, :string
  end

  def self.down
    remove_column :movies, :normalized_tz_title
    remove_column :movies, :normalized_rt_title
  end
end
