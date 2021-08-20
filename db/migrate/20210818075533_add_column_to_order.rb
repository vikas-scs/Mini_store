class AddColumnToOrder < ActiveRecord::Migration[6.1]
  def change
  	remove_column :orders, :product_id
  	add_column :orders, :product_ids, :integer, array: true, default: []
  end
end
