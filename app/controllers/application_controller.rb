# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'app'
require 'extensions'

class ApplicationController < ActionController::Base
  #include ExceptionNotifiable
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :require_authenticated_user

  def test_mailer
    render :text => '<h1>fuck off you git!</h1>', :status => 500
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def require_authenticated_user
    return if authenticate_or_request_with_http_basic do |ident_string, secret_string|
      ident_string == 'karl' && secret_string.to_s.crypt(ident_string)
    end
    render :text => "You must be logged in to view this site", :layout => false, :status => status
  end
end
