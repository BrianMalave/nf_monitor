# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_01_161421) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "device_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "device_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "reported_at", null: false
    t.integer "reported_status", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id", "reported_at"], name: "index_device_reports_on_device_id_and_reported_at"
    t.index ["device_id"], name: "index_device_reports_on_device_id"
  end

  create_table "devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.integer "kind", null: false
    t.datetime "last_reported_at"
    t.bigint "restaurant_id", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id", "identifier"], name: "index_devices_on_restaurant_id_and_identifier", unique: true
    t.index ["restaurant_id"], name: "index_devices_on_restaurant_id"
  end

  create_table "maintenance_logs", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.bigint "device_id", null: false
    t.datetime "ended_at"
    t.text "notes"
    t.datetime "started_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id", "started_at"], name: "index_maintenance_logs_on_device_id_and_started_at"
    t.index ["device_id"], name: "index_maintenance_logs_on_device_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name", "city"], name: "index_restaurants_on_name_and_city", unique: true
  end

  add_foreign_key "device_reports", "devices"
  add_foreign_key "devices", "restaurants"
  add_foreign_key "maintenance_logs", "devices"
end
