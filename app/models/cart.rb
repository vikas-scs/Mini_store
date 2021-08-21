class Cart < ApplicationRecord
	belongs_to :product
	belongs_to :user
	has_and_belongs_to_many :products
end
