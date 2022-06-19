Rails.application.routes.draw do
  root 'home#index'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      match 'cards' => 'forwardes#cards', via: :get
      match 'carts' => 'forwardes#cart', via: :get
      match 'catalogs' => 'forwardes#catalog', via: :get
      match 'produtos' => 'forwardes#products', via: :get
      match 'requests' => 'requests#index', via: :get
    end
  end
end
