# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'app'
require 'extensions'

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def index
    render :layout => 'frameset'
  end
  
  def header
    render
  end
  
  def torrentz
    if params[:q].nil? or params[:searchOrVerified].nil?
      tzpage = TorrentzPage.findOrCreate()
    else
      p = params[:p] || 0
      url = "#{TorrentzPage::SITE_URL}#{params[:searchOrVerified]}?q=#{params[:q]}&p=#{p}"
      tzpage = TorrentzPage.findOrCreate(url)
    end
    session[:torrentz_page_id] = tzpage.id
    
    if tzpage.updated_at <= 5.minutes.ago
      App::call_rake('tz:update_page', :id => tzpage.id)
    elsif !tzpage.movies.nil?
      App::call_rake('tz:load_movies', :id => tzpage.id)
    end
    render :text => tzpage.html
  end
end
