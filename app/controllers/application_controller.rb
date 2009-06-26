# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
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
      render :text => TorrentzPage.get().html
    else
      url = "#{TorrentzPage::SITE_URL}#{params[:searchOrVerified]}?q=#{params[:q]}"
      render :text => TorrentzPage.get(url).html
    end
  end
end
