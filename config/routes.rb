Rails.application.routes.draw do
  get '', to: redirect("/#{I18n.locale}")

  # redsys MerchantURL 
  post '/orders/callback/redsys', to: 'orders#callback_redsys', as: 'orders_callback_redsys'

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

    get '/openid/discover', to: 'open_id#discover', as: "open_id_discover"
    get '/openid', to: 'open_id#index', as: "open_id_index"
    post '/openid', to: 'open_id#create', as: "open_id_create"
    get '/user/:id', to: 'open_id#user', as: "open_id_user"
    get '/user/xrds', to: 'open_id#xrds', as: "open_id_xrds"

    get '/privacy-policy', to: 'page#privacy_policy', as: 'page_privacy_policy'
    get '/preguntas-frecuentes', to: 'page#faq', as: 'faq'
    get '/circulos/validacion', to: 'page#circles_validation', as: 'circles_validation'
    get '/comision-de-garantias-democraticas', to: 'page#guarantees', as: 'guarantees'
    get '/comision-de-garantias-democraticas/conflictos-garantias', to: 'page#guarantees_conflict', as: 'guarantees_conflict'
    get '/comision-de-garantias-democraticas/cumplimento-transparencia', to: 'page#guarantees_compliance', as: 'guarantees_compliance'
    get '/comision-de-garantias-democraticas/etica-validacion', to: 'page#guarantees_ethic', as: 'guarantees_ethic'

    get '/equipos-de-accion-participativa', to: 'participation_teams#index', as: 'participation_teams'
    put '/equipos-de-accion-participativa/entrar(/:team_id)', to: 'participation_teams#join', as: 'participation_teams_join'
    put '/equipos-de-accion-participativa/dejar(/:team_id)', to: 'participation_teams#leave', as: 'participation_teams_leave'
    patch '/equipos-de-accion-participativa/actualizar', to: 'participation_teams#update_user', as: 'participation_teams_update_user'

    get '/responsables-finanzas-legal', to: 'page#town_legal', as: 'town_legal'

    get '/listas-autonomicas', to: 'page#list_register', as: 'list_register'
    get '/avales-candidaturas-barcelona', to: 'page#avales_barcelona', as: 'avales_barcelona'
    get '/primarias-andalucia', to: 'page#primarias_andalucia', as: 'primarias_andalucia'
    get '/listas-primarias-andaluzas', to: 'page#listas_primarias_andaluzas', as: 'listas_primarias_andaluzas'

    get '/responsables-organizacion-municipales', to: 'page#responsables_organizacion_municipales', as: 'responsables_organizacion_municipales'
    get '/responsables-municipales-andalucia', to: 'page#responsables_municipales_andalucia', as:'responsables_municipales_andalucia'
    get '/plaza-podemos-municipal', to: 'page#plaza_podemos_municipal', as:'plaza_podemos_municipal'
    get '/portal-transparencia-cc-estatal', to: 'page#portal_transparencia_cc_estatal', as:'portal_transparencia_cc_estatal'
    get '/mujer-igualdad', to: 'page#mujer_igualdad', as:"mujer_igualdad"
    get '/alta-consulta-ciudadana', to: 'page#alta_consulta_ciudadana', as:"alta_consulta_ciudadana"
    
    get :notices, to: 'notice#index', as: 'notices'
    get '/vote/create/:election_id', to: 'vote#create', as: :create_vote
    get '/vote/create_token/:election_id', to: 'vote#create_token', as: :create_token_vote
    get '/vote/check/:election_id', to: 'vote#check', as: :check_vote
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

    get '/microcreditos', to: 'page#credits', as: 'credits'
    get '/microcreditos/informacion', to: 'page#credits_info', as: 'credits_info'
    get '/microcreditos/colaborar', to: 'page#credits_add', as: 'credits_add'
    
    # http://stackoverflow.com/a/8884605/319241 
    devise_scope :user do
      get '/registrations/regions/provinces', to: 'registrations#regions_provinces'
      get '/registrations/regions/municipies', to: 'registrations#regions_municipies'
      get '/registrations/vote/municipies', to: 'registrations#vote_municipies'
      authenticated :user do

        if not Rails.env.production?
          scope :colabora do
            delete 'baja', to: 'collaborations#destroy', as: 'destroy_collaboration'
            get 'ver', to: 'collaborations#edit', as: 'edit_collaboration'
            get '', to: 'collaborations#new', as: 'new_collaboration'
            get 'confirmar', to: 'collaborations#confirm', as: 'confirm_collaboration'
            post 'crear', to: 'collaborations#create', as: 'create_collaboration'
            get 'OK', to: 'collaborations#OK', as: 'ok_collaboration'
            get 'KO', to: 'collaborations#KO', as: 'ko_collaboration'
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
