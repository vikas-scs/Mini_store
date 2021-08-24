class AddColumnToOrders < ActiveRecord::Migration[6.1]
  def change
  	add_column :orders, :address_id, :integer
  	remove_column :orders_products, :oder_id, :integer
  end
end
