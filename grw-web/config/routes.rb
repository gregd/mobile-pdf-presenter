require 'rw_subdomain'

Rails.application.routes.draw do
  constraints(RwSubdomain::Www) do
    root to: 'www/info#index', as: :www_root
    scope module: :www, as: :www do
      get "info(/index)"      => "info#index"
    end
  end

  constraints(RwSubdomain::Admin) do
    root to: 'admin/accounts#index', as: :admin_root
    scope module: :admin, as: :admin do
      resources :accounts do
        member do
          get :select
        end
      end
      resources :users do
        member do
          post :simulate
        end
      end
      resources :user_roles
      resources :emp_positions
      resources :user_mobile_options, only: [:edit, :update]
      resource :login, only: %i(new create destroy)
      resources :account_configs, only: [:edit, :update]
      resources :app_menu_items do
        collection do
          get :menus
          get :groups
          post :discover
        end
      end
      resources :mobile_logs, only: [:index, :show]
      resources :mobile_time_changes, only: [:index]
      resources :tracker_app_events, only: [:index]
      resources :location_summaries, only: [:index]

      match 'current_web_option'          => 'admin_web_options#update',  :via => :put

      resources :app_action_groups, :app_roles, :app_permissions, :app_modules, :app_role_sets, :mobile_devices
      resources :sms_messages

      namespace :report do
        resources :tracker_app_events, only: [:index]
      end
    end
  end

  constraints(RwSubdomain::Android) do
    namespace :api do
      namespace :android do
        match 'login/new'               => 'login#new',               :via => :post

        match 'data/load'               => 'data#load',               :via => :post
        match 'data/upload'             => 'data#upload',             :via => :post
        match 'data/upload_log'         => 'data#upload_log',         :via => :post

        match 'utils/check'             => 'utils#check',             :via => :post
        match 'utils/download'          => 'utils#download',          :via => :get

        match 'repo/index'               => 'repo#index',             :via => [:get, :post]
        match 'repo/download'            => 'repo#download',          :via => [:get, :post]
      end
    end
  end

  constraints(RwSubdomain::Client) do
    root to: 'dashboard#index', as: :client_root
    get   "dashboard(/index)" => "dashboard#index", as: :dashboard

    resources :org_unit_searches, only: %i(index destroy)
    resources :person_searches, only: %i(index destroy)
    resources :org_units, :persons, :addresses, :person_jobs, :contacts

    namespace :planned do
      resources :activity_visits do
        member do
          post :convert_to_reported
        end
      end
    end
    namespace :reported do
      resources :activity_visits
    end
    resources :activity_visits do
      member do
        get :route
      end
    end

    match "taggings/edit_group"         => "taggings#edit_group",     :via => :get
    match "taggings/update_group"       => "taggings#update_group",   :via => :patch

    match 'current_web_option'          => 'user_web_options#update', :via => :put

    namespace :loc do
      resources :location_summaries

      namespace :report do
        match 'work_time/index'         => 'work_time#index',         :via => :get
      end
    end

    namespace :repo do
      match 'browser/index'             => 'browser#index',           :via => :get
      match 'browser/download'          => 'browser#download',        :via => :get
      match 'browser/mkdir'             => 'browser#mkdir',           :via => :post
      match 'browser/rename'            => 'browser#rename',          :via => :post
      match 'browser/remove'            => 'browser#remove',          :via => :post
      match 'browser/move'              => 'browser#move',            :via => :post
      match 'browser/upload'            => 'browser#upload',          :via => :post

      resources :tracker_items
      resources :tracker_files do
        member do
          get :link
        end
      end

      namespace :report do
        match 'items/index'         => 'items#index',        :via => :get
        match 'total/index'         => 'total#index',        :via => :get
        match 'pages/index'         => 'pages#index',        :via => :get
        match 'receivers/index'     => 'receivers#index',    :via => :get
      end
    end

    resource :login, only: %i(new create destroy) do
      member do
        post :role
        get :simulate
      end
    end

    resources :tags do
      member do
        post :move
      end
    end
    resources :tag_groups
    resources :activity_products, :activity_product_groups

    resources :settings, only: %i(index)
    resource :password, only: %i(new create) do
      member do
        get  :reset
        post :email
        get  :token
        post :verify
      end
    end

    resources :users
    resources :user_roles
    resources :user_addresses
    resources :emp_positions
    resources :geo_areas

    get "info(/index)" => "info#index"
    get "info/android" => "info#android"

    get   "mass_print(/index)" => "mass_print#index", as: :mass_print
    post  "mass_print/pdf", to: "mass_print#pdf", as: :pdf_mass_print

    # shortcut to download apk
    match 'apk' => 'api/android/utils#download', :via => :get
  end

  get 'verify_account' => 'api/android/utils#account'
  get 'no_subdomain' => 'application#no_subdomain'
  get 'no_account' => 'application#no_account'

  root to: redirect {|pp, req|
    if req.subdomain.present?
      addr = req.host_with_port.gsub(/^#{req.subdomain}\./, 'www.')
      "#{req.protocol}#{addr}"
    else
      "#{req.protocol}#{req.host_with_port}/no_subdomain"
    end
  }

  #get '*other', to: redirect {|pp, req| "#{req.protocol}www.#{req.host_with_port}" }
end
