class AddFieldToOrder < ActiveRecord::Migration[6.1]
  def change
  	add_column :orders, :status, :string
  end
end
