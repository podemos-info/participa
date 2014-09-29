Rails.application.routes.draw do

  get '', to: redirect("/#{I18n.locale}")

  # para redsys
  post '/collaborations/validate/callback', to: 'collaborations#callback', as: 'callback_collaboration'
  
  scope "/(:locale)", locale: /es|ca|eu/ do 
    get :notices, to: 'notice#index', as: 'notices'
    scope :validator do
      scope :sms do 
        get :step1, to: 'sms_validator#step1', as: 'sms_validator_step1'
        get :step2, to: 'sms_validator#step2', as: 'sms_validator_step2'
        get :step3, to: 'sms_validator#step3', as: 'sms_validator_step3'
        post :phone, to: 'sms_validator#phone', as: 'sms_validator_phone'
        post :captcha, to: 'sms_validator#captcha', as: 'sms_validator_captcha'
        post :valid, to: 'sms_validator#valid', as: 'sms_validator_valid'
      end
    end
    get '/vote/create/:election_id', to: 'vote#create', as: :create_vote
    devise_for :users, controllers: { 
      registrations: 'registrations', 
      confirmations: 'confirmations'
    } 
    # http://stackoverflow.com/a/8884605/319241 
    devise_scope :user do
      get '/registrations/subregion_options', to: 'registrations#subregion_options'
      authenticated :user do
        scope :collaborations do
          delete 'destroy', to: 'collaborations#destroy', as: 'destroy_collaboration'
          get 'edit', to: 'collaborations#edit', as: 'edit_collaboration'
          get 'new', to: 'collaborations#new', as: 'new_collaboration'
          get 'confirm', to: 'collaborations#confirm', as: 'confirm_collaboration'
          post 'create', to: 'collaborations#create', as: 'create_collaboration'
          scope :validate do
            get 'OK', to: 'collaborations#OK', as: 'validate_ok_collaboration'
            get 'KO', to: 'collaborations#KO', as: 'validate_ko_collaboration'
            get 'status/:order', to: 'collaborations#status', as: 'validate_status_collaboration'
          end
        end
        root 'tools#index', as: :authenticated_root
        get 'password/new', to: 'legacy_password#new', as: 'new_legacy_password'
        post 'password/update', to: 'legacy_password#update', as: 'update_legacy_password'
      end
      unauthenticated do
        root 'devise/sessions#new', as: :root
      end
    end
  end
  # /admin
  ActiveAdmin.routes(self)

  constraints CanAccessResque.new do
    mount Resque::Server.new, at: '/admin/resque', as: :resque
  end

end
