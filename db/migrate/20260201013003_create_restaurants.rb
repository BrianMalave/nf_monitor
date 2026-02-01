class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
