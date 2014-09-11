Rails.application.routes.draw do

  devise_for :users, :controllers => { registrations: 'registrations' } 

  # http://stackoverflow.com/a/8884605/319241 
  devise_scope :user do
    authenticated :user do
      root 'tools#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

end
