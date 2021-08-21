class ProductController < ApplicationController
	def index

	end
	def products
		@products = Product.all
	end
	def search
	end
	def search_item
	    @products = Product.where("name LIKE '%#{params[:name]}%'")     #searching the products based on entered input
	end
	def show_product
		@product = Product.find(params[:id])	
	end
end
