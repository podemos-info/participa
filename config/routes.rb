Rails.application.routes.draw do
  get '', to: redirect("/#{I18n.locale}")

  # redsys MerchantURL 
  post '/collaborations/validate/redsys/callback', to: 'collaborations#redsys_callback', as: 'redsys_callback_collaboration'

  namespace :api do
    scope :v1 do 
      scope :gcm do 
        post 'registrars', to: 'v1#gcm_registrate'
        delete 'registrars/:registrar_id', to: 'v1#gcm_unregister'
      end
      scope :user do
        get 'exists', to: 'v1#user_exists'
      end
    end
  end
  
  scope "/(:locale)", locale: /es|ca|eu/ do 
    get '/privacy-policy', to: 'page#privacy_policy', as: 'page_privacy_policy'
    get '/preguntas-frecuentes', to: 'page#faq', as: 'faq'

    get '/comision-de-garantias-democraticas', to: 'page#guarantees', as: 'guarantees'
    get '/comision-de-garantias-democraticas/conflictos-garantias', to: 'page#guarantees_conflict', as: 'guarantees_conflict'
    get '/comision-de-garantias-democraticas/cumplimento-transparencia', to: 'page#guarantees_compliance', as: 'guarantees_compliance'
    get '/comision-de-garantias-democraticas/etica-validacion', to: 'page#guarantees_ethic', as: 'guarantees_ethic'

    get :notices, to: 'notice#index', as: 'notices'
    get '/vote/create/:election_id', to: 'vote#create', as: :create_vote
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
    devise_for :users, controllers: { 
      registrations: 'registrations', 
      passwords:     'passwords', 
      confirmations: 'confirmations'
    } 
    # http://stackoverflow.com/a/8884605/319241 
    devise_scope :user do
      get '/registrations/regions/provinces', to: 'registrations#regions_provinces'
      get '/registrations/regions/municipies', to: 'registrations#regions_municipies'
      authenticated :user do
        scope :collaborations do
          delete 'destroy', to: 'collaborations#destroy', as: 'destroy_collaboration'
          get 'edit', to: 'collaborations#edit', as: 'edit_collaboration'
          get 'new', to: 'collaborations#new', as: 'new_collaboration'
          get 'confirm', to: 'collaborations#confirm', as: 'confirm_collaboration'
          post 'confirm_bank', to: 'collaborations#confirm_bank', as: 'confirm_bank_collaboration'
          post 'create', to: 'collaborations#create', as: 'create_collaboration'
          scope :validate do
            get 'OK', to: 'collaborations#OK', as: 'validate_ok_collaboration'
            get 'KO', to: 'collaborations#KO', as: 'validate_ko_collaboration'
            scope :redsys do
              get '/status/:order', to: 'collaborations#redsys_status', as: 'redsys_validate_status_collaboration'
            end
          end
        end
        root 'tools#index', as: :authenticated_root
        get 'password/new', to: 'legacy_password#new', as: 'new_legacy_password'
        post 'password/update', to: 'legacy_password#update', as: 'update_legacy_password'
        delete 'password/recover', to: 'registrations#recover_and_logout'
      end
      unauthenticated do
        root 'devise/sessions#new', as: :root
      end
    end

    %w(404 422 500).each do |code|
      get code, to: 'errors#show', code: code
    end
  end
  # /admin
  ActiveAdmin.routes(self)

  constraints CanAccessResque.new do
    mount Resque::Server.new, at: '/admin/resque', as: :resque
  end

end
