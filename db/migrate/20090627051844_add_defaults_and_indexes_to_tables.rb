class AddDefaultsAndIndexesToTables < ActiveRecord::Migration
  def self.up
    # Movie
    add_index :movies, :rt_rating
    add_index :movies, :tz_hash, :unique => true
    
    remove_columns :movies, :loaded, :loading_failed
    add_column :movies, :status, :string
    add_index :movies, :status
    
    # TorrentzPage
    add_index :torrentz_pages, :url, :unique => true
    change_column :torrentz_pages, :url, :string, :null => false
  end

  def self.down
    remove_index :movies, :status
    remove_index :movies, :rt_rating
    remove_index :movies,:tz_hash

    add_column :movies, :loaded, :boolean
    add_column :movies, :loading_failed, :boolean
    remove_column :movies, :status
        
    remove_index :torrentz_pages, :url
    change_column :torrentz_pages, :url, :string, :null => true
  end
end
