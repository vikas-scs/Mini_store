class Order < ApplicationRecord
	belongs_to :user
	belongs_to :coupon, optional: true
	has_many :transactions
	has_and_belongs_to_many :products
	belongs_to :address
end
