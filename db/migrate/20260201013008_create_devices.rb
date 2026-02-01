class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :identifier, null: false
      t.integer :kind, null: false
      t.integer :status, null: false
      t.datetime :last_reported_at

      t.timestamps
    end

    add_index :devices, [:restaurant_id, :identifier], unique: true
  end
end
