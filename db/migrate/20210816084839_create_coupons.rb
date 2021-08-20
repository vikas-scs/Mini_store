class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons do |t|
      t.string :coupon_name
      t.float :amount
      t.float :percentage
      t.integer :usage_count
      t.date :expiry_date

      t.timestamps
    end
  end
end
