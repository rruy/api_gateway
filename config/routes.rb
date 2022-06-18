Rails.application.routes.draw do
  root "home#index"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      match 'cart' => 'proxies#cart', via: :get
      match 'catalog' => 'proxies#catalog', via: :get
    end
  end
end
