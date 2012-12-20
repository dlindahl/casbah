Rails.application.routes.draw do

  match '/login' => 'login#index',       via:'get',  as: :login_form
  match '/login' => 'login#create',      via:'post', as: :login

  match '/logout' => 'logout#index',     via:'get',  as: :logout

  match '/validate' => 'validate#index', via:'get'

  match '/serviceValidate' => 'service_validate#index', via:'get', as: :service_validate

end
