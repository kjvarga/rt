# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'app'
require 'extensions'

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  def test_mailer
    render :text => '<h1>fuck off you git!</h1>', :status => 500
  end
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
