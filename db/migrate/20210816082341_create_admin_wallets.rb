class CreateAdminWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_wallets do |t|
      t.float :balance
      t.integer :admin_id

      t.timestamps
    end
  end
end
