class Product < ApplicationRecord
	belongs_to :order, optional: true
	has_one_attached :image
	has_and_belongs_to_many :orders
	has_and_belongs_to_many :carts
    def product_type_enum
       [['Mobiles'],['Accessories'],['Books'],['cloths'],['Laptops'],['Led tv']]
    end
end
