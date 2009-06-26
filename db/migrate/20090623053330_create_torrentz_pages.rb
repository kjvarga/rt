class CreateTorrentzPages < ActiveRecord::Migration
  def self.up
    create_table :torrentz_pages do |t|
      t.text :html
      t.string :params
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :torrentz_pages
  end
end
