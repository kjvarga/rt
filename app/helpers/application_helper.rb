# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def title
    if @title
      @title + ' - RottenTorrentz'
    else
      "RottenTorrentz - movie info for your torrents"
    end
  end
end
