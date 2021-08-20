class CartController < ApplicationController
	def order
       @orders = Order.where(user_id: current_user.id)
       @orders.first.products
       if @orders.empty?
			flash[:notice] = "No Orders Yet!!!"
			redirect_to root_path
			return
		end
		
	end
	def index
		@wallet = current_user.user_wallet
		@carts = Cart.where(user_id: current_user.id)
		if @carts.empty?
			flash[:notice] = "No items in Cart!!!"
			redirect_to root_path
			return
		end
		@items = Array.new
		@carts.each do |cart|
			@product = Product.find(cart.product_id)
			@items << @product
		end
		
	end
	def add_cart
		if !user_signed_in?
		    flash[:notice] = "Please Login for add item to cart!!!"
			redirect_to new_user_session_path(product_id: params[:id])
		    return
	    end
		@carts = Cart.where(user_id: current_user.id, product_id: params[:id])
		if !@carts.empty?
			flash[:notice] = "Already Added before!!!"
			redirect_to show_product_path(id: params[:id])
			return
		end
		@product = Product.find(params[:id])
		if @product.available_count < params[:quantity].to_i
			flash[:notice] = "only #{@product.available_count} products available"
			redirect_to show_product_path(id: params[:id])
			return
		end
		@product.cart_count = params[:quantity]
		@product.save
		@cart = Cart.new
		@cart.quantity = 1
		@cart.product_id = params[:id]
		@cart.user_id = current_user.id
		if @cart.save
			flash[:notice] = "Added to Cart successfully!!!"
			redirect_to show_product_path(id: params[:id])
		end
	end
	def remove_product
		@cart = Cart.where(user_id: current_user.id, product_id: params[:id]).first
        if @cart.destroy
        	flash[:notice] = "Product removed from Cart!!!"
			redirect_to cart_path
			return
		end
	end
	def quantity
		@product = Product.find(params[:id])
		if @product.available_count < params[:quantity].to_i
			flash[:notice] = "only #{@product.available_count} products available for #{@product.name}"
			redirect_to cart_path
			return
		end
		@product.cart_count = params[:quantity]
		if @product.save
			flash[:notice] = "Quantity changed for #{@product.name}!!!"
			redirect_to cart_path
			return
		end
	end
end
