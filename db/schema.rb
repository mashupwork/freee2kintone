# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151225151248) do

  create_table "banks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallet_txns", force: :cascade do |t|
    t.date     "date"
    t.integer  "amount"
    t.integer  "due_amount"
    t.integer  "balance"
    t.string   "entry_side"
    t.string   "walletable_type"
    t.integer  "walletable_id"
    t.string   "description"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "wallet_txns", ["walletable_id"], name: "index_wallet_txns_on_walletable_id"

  create_table "walletables", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "bank_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "walletables", ["bank_id"], name: "index_walletables_on_bank_id"

end
