class AddColumToCartsproducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :carts_products, :quantity, :integer
  	add_column :orders_products, :quantity, :integer
  	add_column :orders_products, :user_id, :integer
  	add_column :orders_products, :order_id, :integer
  	add_column :carts_products, :user_id, :integer
  end
end
