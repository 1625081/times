Rails.application.routes.draw do
  resources :rooms do
  	collection {post :import}
  end
  root to: 'rooms#index'
  get '/' => 'room#index'
 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
