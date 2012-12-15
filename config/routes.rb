Rails.application.routes.draw do

  match '/cas/login' => 'login#index', via:'get'

end
