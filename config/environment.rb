# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Lines beginning with '#prod' will be uncommented in production by capistrano
#prod ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "haml", :version => ">=2.0.9"
  config.gem 'compass'
  config.gem "jammit"
    
  config.gem "will_paginate"
  config.gem 'sitemap_generator'
  config.gem "friendly_id", :version => ">= 2.3.0"

  # notifications
  config.gem 'hoptoad_notifier'

  # screen scraping
  config.gem "nokogiri", :version => ">=1.3.1"
  config.gem "mechanize", :version => ">=0.9.3"  
  
  # cron tasks
  config.gem 'whenever', :lib => false
    
  config.time_zone = 'Vancouver'

  config.action_mailer.register_template_extension('haml')
end
