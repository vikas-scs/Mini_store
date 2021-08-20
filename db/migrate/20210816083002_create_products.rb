class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :product_type
      t.string :name
      t.float :price
      t.string :features
      t.integer :available_count
      t.integer :cart_count

      t.timestamps
    end
  end
end
