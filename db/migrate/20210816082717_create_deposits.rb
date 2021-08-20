class CreateDeposits < ActiveRecord::Migration[6.1]
  def change
    create_table :deposits do |t|
      t.string :ref_id
      t.string :user_id
      t.string :admin_id
      t.string :status
      t.integer :update_count
      t.float :amount

      t.timestamps
    end
  end
end
