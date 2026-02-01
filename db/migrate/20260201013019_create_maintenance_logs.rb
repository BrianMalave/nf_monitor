class CreateMaintenanceLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_logs do |t|
      t.references :device, null: false, foreign_key: true
      t.string :action, null: false
      t.text :notes
      t.datetime :started_at, null: false
      t.datetime :ended_at

      t.timestamps
    end
    add_index :maintenance_logs, [:device_id, :started_at]
  end
end
