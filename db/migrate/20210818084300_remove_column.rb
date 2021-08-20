class RemoveColumn < ActiveRecord::Migration[6.1]
  def change
  	remove_column :orders, :product_ids
  end
end
