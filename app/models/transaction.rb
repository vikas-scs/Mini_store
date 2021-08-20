class Transaction < ApplicationRecord
	belongs_to :deposit, optional: true
	belongs_to :order, optional: true
	belongs_to :user
	belongs_to :admin, optional: true
end
