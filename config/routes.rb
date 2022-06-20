Rails.application.routes.draw do
  root 'home#index'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      match 'cards' => 'forwardes#cards', via: :get
      match 'carts' => 'forwardes#cart', via: :get
      match 'catalogs' => 'forwardes#catalog', via: :get
      match 'produtos' => 'forwardes#products', via: :get
      match 'requests' => 'requests#index', via: :get
      match 'requests/errors' => 'requests#errors', via: :get
      match 'requests/per_day' => 'requests#per_day', via: :get
      match 'requests/per_hours' => 'requests#per_hours', via: :get
    end
  end
end
