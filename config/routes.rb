require 'dynamic_router'
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
    get '/comision-de-garantias-democraticas/comunicacion', to: 'page#guarantees_form', as: 'guarantees_form'

    get '/gente-por-el-cambio', to: redirect('/equipos-de-accion-participativa')
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
    get '/solicitud-consulta-ciudadana-candidatura-unidad-popular', to: 'page#alta_consulta_ciudadana', as:"alta_consulta_ciudadana"
    get '/representantes-electorales-extranjeros', to: 'page#representantes_electorales_extranjeros', as:"representantes_electorales_extranjeros"
    get '/responsables-areas-cc-autonomicos', to: 'page#responsables_areas_cc_autonomicos', as:"responsables_areas_cc_autonomicos"
    get '/boletin-correo-electronico', to: 'page#boletin_correo_electronico', as:"boletin_correo_electronico"
    get '/responsable-web-autonomico', to: 'page#responsable_web_autonomico', as: 'responsable_web_autonomico'
    
    get '/comparte-el-cambio', to: 'page#demo', as: 'demo'
    get '/comparte-el-cambio/compartir-casa', to: 'page#offer_hospitality', as: 'offer_hospitality'
    get '/comparte-el-cambio/encuentra-casa', to: 'page#find_hospitality', as: 'find_hospitality'
    get '/comparte-el-cambio/compartir-coche-sevilla', to: 'page#share_car_sevilla', as: 'share_car_sevilla'
    get '/comparte-el-cambio/encuentra-viaje-sevilla', to: 'page#find_car_sevilla', as: 'find_car_sevilla'
    get '/comparte-el-cambio/compartir-coche-doshermanas', to: 'page#share_car_doshermanas', as: 'share_car_doshermanas'
    get '/comparte-el-cambio/encuentra-viaje-doshermanas', to: 'page#find_car_doshermanas', as: 'find_car_doshermanas'
    get '/comparte-el-cambio/valoracion-propietarios', to: 'page#comparte_cambio_valoracion_propietarios', as: 'comparte_cambio_valoracion_propietarios'
    get '/comparte-el-cambio/valoracion-usuarios', to: 'page#comparte_cambio_valoracion_usuarios', as: 'comparte_cambio_valoracion_usuarios'

    get '/apoderados-campana-autonomica-andalucia', to: 'page#apoderados_campana_autonomica_andalucia', as: 'apoderados_campana_autonomica_andalucia'
    get '/candidaturas-primarias-autonomicas', to: 'page#candidaturas_primarias_autonomicas', as: 'candidaturas_primarias_autonomicas'
    get '/listas-primarias-autonomicas', to: 'page#listas_primarias_autonomicas', as: 'listas_primarias_autonomicas'
    get '/avales-candidaturas-primarias', to: 'page#avales_candidaturas_primarias', as: 'avales_candidaturas_primarias'
    get '/iniciativa-ciudadana', to: 'page#iniciativa_ciudadana', as: 'iniciativa_ciudadana'

    get '/cuentas-consejos-autonomicos-33', to: 'page#cuentas_consejos_autonomicos', as: 'cuentas_consejos_autonomicos'
    get '/condiciones-uso-correo-34', to: 'page#condiciones_uso_correo', as: 'condiciones_uso_correo'

    get '/propuestas', to: 'proposals#index', as: 'proposals'
    get '/propuestas/info', to: 'proposals#info', as: 'proposals_info'
    get '/propuestas/:id', to: 'proposals#show', as: 'proposal'
    post '/apoyar/:proposal_id', to: 'supports#create', as: 'proposal_supports'

    get :notices, to: 'notice#index', as: 'notices'
    get '/vote/create/:election_id', to: 'vote#create', as: :create_vote
    get '/vote/create_token/:election_id', to: 'vote#create_token', as: :create_token_vote
    get '/vote/check/:election_id', to: 'vote#check', as: :check_vote
    
    devise_for :users, controllers: { 
      registrations: 'registrations', 
      passwords:     'passwords', 
      confirmations: 'confirmations'
    } 

    get '/microcreditos', to: 'microcredit#index', as: 'microcredit'
    get '/microcréditos', to: redirect('/microcreditos')
    get '/microcreditos/provincias', to: 'microcredit#provinces'
    get '/microcreditos/municipios', to: 'microcredit#towns'
    get '/microcreditos/informacion', to: 'microcredit#info', as: 'microcredits_info'
    get '/microcreditos/:id', to: 'microcredit#new_loan', as: :new_microcredit_loan
    get '/microcreditos/:id/login', to: 'microcredit#login', as: :microcredit_login
    post '/microcreditos/:id', to: 'microcredit#create_loan', as: :create_microcredit_loan
    
    authenticate :user do
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
      
      scope :colabora do
        delete 'baja', to: 'collaborations#destroy', as: 'destroy_collaboration'
        get 'ver', to: 'collaborations#edit', as: 'edit_collaboration'
        get '', to: 'collaborations#new', as: 'new_collaboration'
        get 'confirmar', to: 'collaborations#confirm', as: 'confirm_collaboration'
        post 'crear', to: 'collaborations#create', as: 'create_collaboration'
        post 'modificar', to: 'collaborations#modify', as: 'modify_collaboration'
        get 'OK', to: 'collaborations#OK', as: 'ok_collaboration'
        get 'KO', to: 'collaborations#KO', as: 'ko_collaboration'
      end

      scope :brujula do
        get '', to: 'blog#index', as: 'blog'
        get ':id', to: 'blog#post', as: 'post'
        get 'categoria/:id', to: 'blog#category', as: 'category'
      end
    end

    # http://stackoverflow.com/a/8884605/319241 
    devise_scope :user do
      get '/registrations/regions/provinces', to: 'registrations#regions_provinces'
      get '/registrations/regions/municipies', to: 'registrations#regions_municipies'
      get '/registrations/vote/municipies', to: 'registrations#vote_municipies'

      authenticated :user do
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

    DynamicRouter.load
  end
  # /admin
  ActiveAdmin.routes(self)

  constraints CanAccessResque.new do
    mount Resque::Server.new, at: '/admin/resque', as: :resque
  end

end
