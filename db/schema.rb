# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_07_08_061712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_currencies_on_code", unique: true
  end

  create_table "exchange_rate_movements", force: :cascade do |t|
    t.string "code", null: false
    t.integer "exchange_rate_id", null: false
    t.date "effective_date", null: false
    t.float "rate", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_exchange_rate_movements_on_code", unique: true
    t.index ["exchange_rate_id", "effective_date"], name: "exchange_rate_movement_uniq_index", unique: true
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "code", null: false
    t.integer "from_currency_id", null: false
    t.integer "to_currency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_exchange_rates_on_code", unique: true
    t.index ["from_currency_id", "to_currency_id"], name: "exchange_rate_uniq_index", unique: true
  end

  add_foreign_key "exchange_rate_movements", "exchange_rates"
  add_foreign_key "exchange_rates", "currencies", column: "from_currency_id"
  add_foreign_key "exchange_rates", "currencies", column: "to_currency_id"
end
