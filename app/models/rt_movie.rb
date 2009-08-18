class RtMovie < ActiveRecord::Base
  GENRES = ['Action/Adventure', 'Animation', 'Comedies', 'Documentaries', 'Dramas', 'Foreign', 'Horror/Suspense', 'Kids/Family', 'Romance', 'Sci-Fi/Fantasy', 'Special Interest', 'Thriller']
  
  has_many :tz_movies
  validates_uniqueness_of :link
end


# == Schema Info
# Schema version: 20090815080340
#
# Table name: rt_movies
#
#  id               :integer         not null, primary key
#  genre            :string(255)
#  img              :string(255)
#  info             :text
#  link             :string(255)
#  normalized_title :string(255)
#  rating           :integer         default(0)
#  title            :string(255)
#  year             :integer
#  created_at       :datetime
#  updated_at       :datetime