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

ActiveRecord::Schema.define(:version => 20100308074028) do

  create_table "movies", :force => true do |t|
    t.string   "tz_link"
    t.string   "rt_link"
    t.integer  "year"
    t.string   "rt_img"
    t.integer  "rt_rating",           :default => 0
    t.text     "rt_info"
    t.string   "rt_title"
    t.string   "tz_title"
    t.string   "tz_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "normalized_tz_title"
    t.string   "normalized_rt_title"
  end

  add_index "movies", ["rt_rating"], :name => "index_movies_on_rt_rating"
  add_index "movies", ["status"], :name => "index_movies_on_status"
  add_index "movies", ["tz_hash"], :name => "index_movies_on_tz_hash", :unique => true

  create_table "rt_movies", :force => true do |t|
    t.string   "img"
    t.string   "link"
    t.integer  "year"
    t.text     "info"
    t.integer  "rating",           :default => 0
    t.string   "title"
    t.string   "normalized_title"
    t.string   "genre"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rt_movies", ["genre"], :name => "index_rt_movies_on_genre"
  add_index "rt_movies", ["link"], :name => "index_rt_movies_on_link", :unique => true
  add_index "rt_movies", ["rating"], :name => "index_rt_movies_on_rating"
  add_index "rt_movies", ["year"], :name => "index_rt_movies_on_year"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "torrentz_pages", :force => true do |t|
    t.text     "html"
    t.string   "params"
    t.string   "url",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tz_movies"
  end

  add_index "torrentz_pages", ["url"], :name => "index_torrentz_pages_on_url", :unique => true

  create_table "tz_movies", :force => true do |t|
    t.string   "movie_hash",                      :null => false
    t.string   "link"
    t.string   "title"
    t.string   "normalized_title"
    t.string   "status"
    t.integer  "rt_movie_id"
    t.string   "last_updated"
    t.boolean  "verified"
    t.integer  "size",             :default => 0
    t.integer  "seeds",            :default => 0
    t.integer  "peers",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percent",          :default => 0
  end

  add_index "tz_movies", ["movie_hash"], :name => "index_tz_movies_on_movie_hash"
  add_index "tz_movies", ["percent"], :name => "index_tz_movies_on_percent"
  add_index "tz_movies", ["status"], :name => "index_tz_movies_on_status"

end
