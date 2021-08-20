class CreateCouponsUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons_users do |t|
      t.integer :user_id
      t.integer :coupon_id

      t.timestamps
    end
  end
end
