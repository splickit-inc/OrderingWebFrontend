Splickit::Application.routes.draw do

  root to: 'merchants#index'

  get '/sign_in', to: 'sessions#new', as: 'sign_in'
  get '/sign_out', to: 'sessions#destroy', as: 'sign_out'
  get '/session_status', to: 'sessions#session_status', as: 'session_status'
  get '/sign_up', to: 'users#new', as: 'sign_up'

  get '/404', :to => 'errors#error_404', as: 'error_404'
  get '/422', :to => 'errors#error_422', as: 'error_422'
  get '/500', :to => 'errors#error_500', as: 'error_500'
  get '/590', :to => 'errors#error_590', as: 'error_590'

  get '/reset_password/:token', :to => 'password_resets#request_reset'
  get '/request_email', :to => 'password_resets#request_email'
  get '/request_token', :to => 'password_resets#request_token'
  get '/request_reset', :to => 'password_resets#request_reset'
  post '/request_reset', :to => 'password_resets#update_password', as: 'update_password'

  get '/feedback', to: 'feedbacks#new'

  get '/app', to: 'apps#show'
  get '/sms_app_link', to: 'apps#redirect_to_app_store'

  resource :healthchecks, path: 'healthcheck', only: [] do
    get '/', to: 'healthchecks#new'
  end

  resource :guests, only: [] do
    get 'sign_up', to: 'guests#new'
  end

  resource :facebook do
    post '/sign_in', to: 'sessions#create'
  end

  resources :skins, only: [] do
    collection do
      post :service
    end
  end

  resources :group_orders, only: [] do
    member do
      post :submit
      get :success
      post '/increment/:time', to: 'group_orders#increment'
    end

    collection do
      delete :destroy
      post :create
      get '/new', to: 'group_orders#new'

      get :confirmation
      get :inactive
      get :add_items
      delete :remove_item
    end
  end

  get '/group_order/:id', :id => /.+-.+/, to: 'group_orders#show', as: 'group_order'

  scope '/cache' do
    post '/clear_merchant/:id', to: 'cache#clear_merchant'
    post '/clear_merchants',    to: 'cache#clear_merchants'
    post '/clear_skin',         to: 'cache#clear_skin'
    post '/warm',               to: 'cache#warm_cache'
  end

  resource :user, only: [:create] do
    get  :account
    put :update_account, to: 'users#update_account', as: 'update_account'
    post :add, to: "users#add_gift_card"
    get  :orders_history

    resource :loyalty, only: [:show] do
      get :manage
      get :history
      get :rules
      post :update_card
    end

    resources :address, controller: :user_addresses, only: [:index, :new, :create, :destroy]
    resources :payment, controller: :user_payments, only: [:new, :create] do
      delete :destroy, on: :collection
    end
  end

  resources :sessions, only: [:create]
  resource :feedback, only: [:create]
  resources :checkouts, only: [:new, :create]

  post 'checkouts/apply_promo', to: 'checkouts#apply_promo', as: 'apply_promo'
  get '/checkouts/get_times_by_day', to: 'checkouts#get_times_by_day'
  get '/last_order', to: 'checkouts#show', as: 'last_order'

  get 'merchants',     to: 'merchants#index'
  get 'merchants/:id', to: 'merchants#show', constraints: { id: /[0-9]*/ }, as: 'merchant'

  get 'merchants/:id/group_order_available_times/:order_type', to: 'merchants#group_order_available_times', constraints: { id: /[0-9]*/ }, as: 'merchant_group_order_available_times'
  get 'merchants/:id/nutrition',     to: 'merchants#nutrition_sizes_information'

  get '/empty_cart', to: 'checkouts#empty_cart', as: 'empty_cart'

  scope 'order' do
    get    '/',         to: 'orders#show'
    delete '/',         to: 'orders#destroy'
    get    '/item/:id', to: 'orders#show_item'
    put    '/item/:id', to: 'orders#update_item'
    post   '/item',     to: 'orders#create_item'
    delete '/item/:id', to: 'orders#delete_item'

    get '/checkout', to: 'orders#checkout'
  end

  resources :favorites, controller: 'user_favorites', only: [:create, :destroy]

  ## legacy routing concerns ##
  get '/order/*legacy/:id', to: redirect('/merchants'), :constraints => { :subdomain => /pitapit/ }
  get '/order/*legacy/:id', to: redirect('/merchants/%{id}?order_type=pickup')

  ##catering section
  resources :caterings, only: [:new, :create] do
	  collection do
      get :update_delivery_address #TODO change to post, it implies a lot of changes tho
      get :times
	  end
  end
  get '/caterings/begin', to: 'caterings#begin'

end
