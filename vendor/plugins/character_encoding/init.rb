# Include hook code here
require 'character_encoding'
ActiveRecord::Base.send(:include, ActiveRecord::CharacterEncoding)