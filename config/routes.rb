Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: 'registrations', confirmations: 'confirmations' } 

  # http://stackoverflow.com/a/8884605/319241 
  devise_scope :user do
    get '/registrations/subregion_options', to: 'registrations#subregion_options'

    authenticated :user do
      root 'tools#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :root
    end
  end

end
