class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.string :ref_id
      t.integer :deposit_id
      t.integer :order_id
      t.integer :user_id
      t.integer :admin_id
      t.string :transaction_type
      t.float :amount
      t.string :description
      t.float :remaining_balance

      t.timestamps
    end
  end
end
