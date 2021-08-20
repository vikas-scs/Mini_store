class Product < ApplicationRecord
	has_many :carts
	belongs_to :order, optional: true
	has_one_attached :image
	has_and_belongs_to_many :orders
    def product_type_enum
       [['Mobiles'],['Accessories'],['Books'],['cloths'],['Laptops'],['Led tv']]
    end
end
