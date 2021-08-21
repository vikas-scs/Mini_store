class CartController < ApplicationController
	def order
       @orders = Order.where(user_id: current_user.id)
       puts @orders               #getting the current user orders list
       @ops = OrdersProduct.where(user_id: current_user.id)
	end
	def index
		puts "hello"       
		@wallet = current_user.user_wallet
		@carts = Cart.where(user_id: current_user.id)
		       #getting the cart items available in current user
		@cps = CartsProduct.where(user_id: current_user.id) 
		puts @cps                                          #getting the cart products in array	
	end
	def add_cart 
		if !user_signed_in?                                       #redirecting to user login page if user wasn't login before and try to add product to cart
		    flash[:notice] = "Please Login for add item to cart!!!"
			redirect_to new_user_session_path(product_id: params[:id])
		    return
	    end
		@carts = Cart.where(user_id: current_user.id, product_id: params[:id])        #displaying the message if item is already added in cart
		if !@carts.empty?
			flash[:notice] = "Already Added before!!!"
			redirect_to show_product_path(id: params[:id])
			return
		end
		@product = Product.find(params[:id])
		if params[:quantity].to_i <= 0
			flash[:notice] = "invalid quantity for #{@product.name}"
			redirect_to show_product_path(id: params[:id])
			return
		end                        #checking product availabilty
		if @product.available_count < params[:quantity].to_i
			flash[:notice] = "only #{@product.available_count} products available"
			redirect_to show_product_path(id: params[:id])
			return
		end
		@product.cart_count = params[:quantity]
		@product.save
		@cart = Cart.new                                           #adding the product to cart
		@cart.quantity = 1
		@cart.product_id = params[:id]
		@cart.user_id = current_user.id
		@cp = CartsProduct.new
		@cp.product_id = params[:id]
		if @cart.save
			@cp.quantity = @product.cart_count
			@cp.cart_id = @cart.id
			@cp.user_id = current_user.id
			@cp.save
			flash[:alert] = "Added to Cart successfully!!!"
			redirect_to cart_path
		end
	end
	def remove_product
		@cart = Cart.where(user_id: current_user.id, product_id: params[:id]).first       #removing the desired product from the cart
        if @cart.destroy
        	flash[:alert] = "Product removed from Cart!!!"
			redirect_to cart_path
			return
		end
	end
	def quantity
		@product = Product.find(params[:id]) 
		                           #checking product availabilty  
		if params[:quantity].to_i <= 0
			flash[:notice] = "invalid quantity for #{@product.name}"
			redirect_to cart_path
			return
		end
			      
		if @product.available_count < params[:quantity].to_i
			flash[:notice] = "only #{@product.available_count} products available for #{@product.name}"
			redirect_to cart_path
			return
		end
		@cp = CartsProduct.where(product_id: @product.id, cart_id:current_user.carts.first.id).first
		@cp.quantity = params[:quantity]
		@product.cart_count = params[:quantity]
		@cp.save
		if @product.save                                    #changing the product quantity from the cart
			flash[:alert] = "Quantity changed for #{@product.name}!!!"
			redirect_to cart_path
			return
		end
	end
end
