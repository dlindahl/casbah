Rails.application.routes.draw do

  match '/cas/login' => 'login#index',       via:'get',  as: :login_form
  match '/cas/login' => 'login#create',      via:'post', as: :login

end
