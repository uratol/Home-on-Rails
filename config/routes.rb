private

def actions
  get '' => 'main#show'
  post '/refresh' => 'main#refresh'
  post '/click' => 'main#click'
  post '/change' => 'main#change'
  post '/touchstart' => 'main#touchstart'
  post '/touchend' => 'main#touchend'
end

def uni_routes
  get 'entities/classes'
  resources :entities
  get '/entities/:id/destroy' => 'entities#destroy'
  get '/entities/insert/:parent' => 'entities#insert'


  scope '/show/:name(/:subname)' do
    actions
  end

  scope '/' do
    actions
  end

  post '/refresh' => 'main#refresh'

  post '/presence' => 'http_driver#ping'

  post '/admin/reboot'
  
  post '/main/design_apply'

  scope :butler do
    post '/command' => "butler#command"
    get '/command' => "butler#command"
  end

#  post '/remote' => "remote#execute"
  get '/remote' => "remote#execute"

#  get '/driver/read' => "http_driver#read"
#  get '/driver/write' => "http_driver#write"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'main#show'

  scope :api do
    get "/tts/:lang/" => "speech#speak"
    get "/command/:command/" => "speech#speak"
  end

  devise_for :users, controllers: { sessions: "users/sessions" }
  resources :users
  resources :drivers
  resource :network
end

public

Home::Engine.routes.draw do
  uni_routes
end

Rails.application.routes.draw do
  uni_routes
end

