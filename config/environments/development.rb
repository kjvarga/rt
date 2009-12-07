# Settings specified here will take precedence over those in config/environment.rb
config.gem "sqlite3-ruby", :lib => "sqlite3"
config.gem 'bullet', :source => 'http://gemcutter.org'
  
# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true

# Caching
config.action_controller.perform_caching             = true
#config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true
#config.action_mailer.delivery_method = :test
config.action_mailer.delivery_method = :sendmail
config.action_mailer.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => "-i -t -O DeliveryMode='b'"
}

Sass::Plugin.options[:style] = :compact

config.after_initialize do
  Bullet.enable = true 
  Bullet.alert = true
  Bullet.bullet_logger = true  
  Bullet.console = true
  Bullet.growl = true
  Bullet.rails_logger = true
  Bullet.disable_browser_cache = true
end