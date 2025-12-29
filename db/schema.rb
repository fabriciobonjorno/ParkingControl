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

ActiveRecord::Schema[8.1].define(version: 2025_12_29_160814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "parkings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "left_at"
    t.datetime "paid_at"
    t.string "plate", null: false
    t.datetime "started_at", null: false
    t.datetime "updated_at", null: false
    t.index ["left_at"], name: "index_parkings_on_left_at"
    t.index ["paid_at"], name: "index_parkings_on_paid_at"
    t.index ["plate"], name: "index_parkings_on_plate"
    t.index ["started_at"], name: "index_parkings_on_started_at"
  end
end
