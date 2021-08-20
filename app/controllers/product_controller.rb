class ProductController < ApplicationController
	def index
		if user_signed_in? 
           @wallet = current_user.user_wallet
		end
	end
	def products
		@products = Product.all
		if user_signed_in? 
		 @wallet = current_user.user_wallet
		end
	end
	def search
	end
	def search_item
	    @products = Product.where("name LIKE '#{params[:name]}%'")
	    puts @products
	    puts "hello"
	end
	def show_product
		@product = Product.find(params[:id])	
	end
end
