class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :user_wallet
  has_many :deposits
  has_many :carts
  has_many :addresses
  has_many :orders
  has_many :transactions
  has_and_belongs_to_many :coupons
  validates :name, presence: :true, format: { with: /\A[a-zA-Z]+\z/}, uniqueness: true
   validates :mobile, format: { with: /\A[6-9]{1}\d{9}\z/ }, uniqueness: true, presence: :true
end
