Rails.application.routes.draw do

  scope "/(:locale)", locale: /es|ca|eu/ do 

    get '/mapa', to: 'page#map', as: 'map'
    get '/calendario', to: 'page#calendar', as: 'calendar'
    get '/social', to: 'page#social', as: 'social'

  end

end
