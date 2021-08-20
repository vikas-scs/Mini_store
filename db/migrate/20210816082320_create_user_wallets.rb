class CreateUserWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :user_wallets do |t|
      t.float :balance
      t.integer :user_id

      t.timestamps
    end
  end
end
