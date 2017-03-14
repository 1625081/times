Rails.application.routes.draw do
  get 'users/signup'
  resources :users, only: [:create]
  resources :rooms do
  	collection {post :import,:search,:more}
  end
  root to: 'rooms#index'
  get '/' => 'rooms#index',format: true

  get "signup" => "users#signup", :as => "signup"
  get "login" => "users#login", :as => "login"
  delete "logout" => "users#logout", :as => "logout"
  post "create_login_session" => "users#create_login_session"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
