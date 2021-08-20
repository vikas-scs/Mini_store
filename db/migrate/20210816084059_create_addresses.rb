class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :d_no
      t.string :street
      t.string :village
      t.string :state
      t.string :pincode

      t.timestamps
    end
  end
end
