class AddFieldsToOders < ActiveRecord::Migration[6.1]
  def change
  	add_column :orders, :final_amount, :float
  	add_column :orders, :coupon_benifit, :float
  	add_column :orders, :delivery_date, :date
  end
end
