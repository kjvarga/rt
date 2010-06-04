ActionController::Routing::Routes.draw do |map|
  
  map.movie ':id', :controller => 'movies', :action => :show
  map.root :controller => 'torrentz'
  
  Jammit::Routes.draw(map)
end
