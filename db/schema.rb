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

ActiveRecord::Schema.define(:version => 20090623053330) do

  create_table "movies", :force => true do |t|
    t.string   "tz_link"
    t.string   "rt_link"
    t.integer  "year"
    t.boolean  "loaded"
    t.boolean  "loading_failed"
    t.string   "rt_img"
    t.integer  "rt_rating"
    t.text     "rt_info"
    t.string   "rt_title"
    t.string   "tz_title"
    t.string   "tz_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "torrentz_pages", :force => true do |t|
    t.text     "html"
    t.string   "params"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
