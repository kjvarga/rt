# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rt_session',
  :secret      => 'd28f45379bab593667592db7397cc23ab7cf68bb720987b8b0af0a6ce95da1edbbc8f18d9508dfe7adb3ba6a08921fe0d3500e25b8e7c42608f3e495e494d0dc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
