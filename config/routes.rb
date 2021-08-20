Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :admins
 devise_for :users, :controllers =>{ registrations: "user/registrations", sessions: "user/sessions"} 
  root "product#index"
  get "product/products", to:"product#products", as: :products
  get "product/search_item", to:"product#search_item", as: :search_product
  get "product/show_product", to:"product#show_product", as: :show_product
  get "product/search", to:"product#search", as: :search
  get "cart/index", to:"cart#index", as: :cart
  get "cart/order", to:"cart#order", as: :order
  get "cart/remove_product", to:"cart#remove_product", as: :remove_product
  get "cart/add_cart", to:"cart#add_cart", as: :add_cart
  get "product/index", to:"product#index"
  get "wallet/index", to:"wallet#index", as: :wallets
  get "wallet/:id", to:"wallet#new", as: :new_wallet
  post 'wallet/:id', to: 'wallet#create'
  get "cart/quantity", to:"cart#quantity", as: :quantity
  get "order/address", to:"order#address", as: :address
  get "order/select_address", to:"order#select_address", as: :select_address
  get "order/place_order", to:"order#place_order", as: :place_order
  get "order/coupon", to:"order#coupon", as: :coupon
  get "order/confirm", to:"order#confirm", as: :confirm
  get "order/order_detail", to:"order#order_detail", as: :order_detail
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
