class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :ref_id
      t.integer :user_id
      t.integer :product_id
      t.integer :coupon_id

      t.timestamps
    end
  end
end
