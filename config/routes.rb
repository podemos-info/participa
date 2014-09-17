Rails.application.routes.draw do

  get :notices, to: 'notice#index', as: 'notices'

  scope :validator do
    get :step1, to: 'sms_validator#step1', as: 'sms_validator_step1'
    post :phone, to: 'sms_validator#step1', as: 'sms_validator_phone'
    get :step2, to: 'sms_validator#step2', as: 'sms_validator_step2'
    post :captcha, to: 'sms_validator#captcha', as: 'sms_validator_captcha'
    get :step3, to: 'sms_validator#step3', as: 'sms_validator_step3'
    post :valid, to: 'sms_validator#valid', as: 'sms_validator_valid'
  end

  ActiveAdmin.routes(self)

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
