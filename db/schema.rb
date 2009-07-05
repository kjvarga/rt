# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090705150709) do

  create_table "movies", :force => true do |t|
    t.string   "tz_link"
    t.string   "rt_link"
    t.integer  "year"
    t.string   "rt_img"
    t.integer  "rt_rating",  :default => 0
    t.text     "rt_info"
    t.string   "rt_title"
    t.string   "tz_title"
    t.string   "tz_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  add_index "movies", ["rt_rating"], :name => "index_movies_on_rt_rating"
  add_index "movies", ["status"], :name => "index_movies_on_status"
  add_index "movies", ["tz_hash"], :name => "index_movies_on_tz_hash", :unique => true

  create_table "torrentz_pages", :force => true do |t|
    t.text     "html"
    t.string   "params"
    t.string   "url",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "torrentz_pages", ["url"], :name => "index_torrentz_pages_on_url", :unique => true

end
