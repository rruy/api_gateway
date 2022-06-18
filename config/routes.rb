Rails.application.routes.draw do
  root 'home#index'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      match 'carts' => 'forwardes#cart', via: :get
      match 'catalogs' => 'forwardes#catalog', via: :get
      match 'requests' => 'forwardes#index', via: :get
    end
  end
end
