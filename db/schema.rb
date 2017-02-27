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

ActiveRecord::Schema.define(version: 20170221102859) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "bank",        limit: 255
    t.string   "bank_branch", limit: 255
    t.string   "category",    limit: 255
    t.string   "ac_no",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "my_group",                default: false
  end

  create_table "bank_account_balances", force: :cascade do |t|
    t.integer  "my_account_id",        limit: 4
    t.integer  "current_amount",       limit: 8
    t.date     "estimated_on"
    t.integer  "current_month_amount", limit: 8
    t.integer  "two_month_amount",     limit: 8
    t.integer  "three_month_amount",   limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "estimate_date_amount", limit: 8
    t.date     "based_on"
  end

  create_table "bank_transfers", force: :cascade do |t|
    t.integer  "receipt_header_id", limit: 4
    t.integer  "payment_header_id", limit: 4
    t.date     "target_date"
    t.integer  "amount",            limit: 4
    t.integer  "src_my_account_id", limit: 4
    t.integer  "dst_my_account_id", limit: 4
    t.integer  "src_item_id",       limit: 4
    t.integer  "dst_item_id",       limit: 4
    t.integer  "project_id",        limit: 4
    t.integer  "user_id",           limit: 4
    t.text     "comment",           limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "bank_transfers", ["dst_item_id"], name: "index_bank_transfers_on_dst_item_id", using: :btree
  add_index "bank_transfers", ["dst_my_account_id"], name: "index_bank_transfers_on_dst_my_account_id", using: :btree
  add_index "bank_transfers", ["payment_header_id"], name: "index_bank_transfers_on_payment_header_id", using: :btree
  add_index "bank_transfers", ["project_id"], name: "index_bank_transfers_on_project_id", using: :btree
  add_index "bank_transfers", ["receipt_header_id"], name: "index_bank_transfers_on_receipt_header_id", using: :btree
  add_index "bank_transfers", ["src_item_id"], name: "index_bank_transfers_on_src_item_id", using: :btree
  add_index "bank_transfers", ["src_my_account_id"], name: "index_bank_transfers_on_src_my_account_id", using: :btree
  add_index "bank_transfers", ["user_id"], name: "index_bank_transfers_on_user_id", using: :btree

  create_table "casein_admin_users", force: :cascade do |t|
    t.string   "login",               limit: 255,             null: false
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
    t.integer  "access_level",        limit: 4,   default: 0, null: false
    t.string   "crypted_password",    limit: 255,             null: false
    t.string   "password_salt",       limit: 255,             null: false
    t.string   "persistence_token",   limit: 255
    t.string   "single_access_token", limit: 255
    t.string   "perishable_token",    limit: 255
    t.integer  "login_count",         limit: 4,   default: 0, null: false
    t.integer  "failed_login_count",  limit: 4,   default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",    limit: 255
    t.string   "last_login_ip",       limit: 255
    t.string   "time_zone",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "member_code",         limit: 255
    t.string   "section",             limit: 255
  end

  create_table "items", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "group",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "my_accounts", force: :cascade do |t|
    t.string   "bank",             limit: 255
    t.string   "bank_branch",      limit: 255
    t.string   "category",         limit: 255
    t.string   "ac_no",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "corporation_code", limit: 4
    t.string   "org_name",         limit: 255
  end

  add_index "my_accounts", ["corporation_code"], name: "index_my_accounts_on_corporation_code", using: :btree

  create_table "my_corporations", id: false, force: :cascade do |t|
    t.integer  "code",       limit: 4,   null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "my_corporations", ["code"], name: "index_my_corporations_on_code", unique: true, using: :btree

  create_table "number_masters", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "now_val",    limit: 4
    t.integer  "max_val",    limit: 4
    t.integer  "min_val",    limit: 4
    t.string   "prefix",     limit: 255
    t.integer  "steps",      limit: 4,   default: 1
    t.string   "type",       limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "number_masters", ["type"], name: "index_number_masters_on_type", using: :btree

  create_table "payment_headers", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "account_id",        limit: 4
    t.date     "payable_on"
    t.integer  "project_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slip_no",           limit: 255
    t.text     "comment",           limit: 65535
    t.string   "budget_code",       limit: 255
    t.string   "fee_who_paid",      limit: 255
    t.integer  "my_account_id",     limit: 4
    t.boolean  "planned",                         default: false
    t.boolean  "processed",                       default: false
    t.integer  "process_user_id",   limit: 4
    t.date     "process_date"
    t.boolean  "no_monthly_report",               default: false
    t.string   "payment_type",      limit: 255
    t.boolean  "monthly_data",                    default: false
    t.integer  "corporation_code",  limit: 4
    t.string   "org_name",          limit: 255
  end

  add_index "payment_headers", ["corporation_code"], name: "index_payment_headers_on_corporation_code", using: :btree
  add_index "payment_headers", ["my_account_id"], name: "index_payment_headers_on_my_account_id", using: :btree
  add_index "payment_headers", ["process_user_id"], name: "index_payment_headers_on_process_user_id", using: :btree

  create_table "payment_parts", force: :cascade do |t|
    t.integer  "payment_header_id", limit: 4
    t.integer  "item_id",           limit: 4
    t.integer  "amount",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "category",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "my_account_id", limit: 4
  end

  add_index "projects", ["my_account_id"], name: "index_projects_on_my_account_id", using: :btree

  create_table "receipt_headers", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "account_id",        limit: 4
    t.date     "receipt_on"
    t.integer  "project_id",        limit: 4
    t.text     "comment",           limit: 65535
    t.integer  "item_id",           limit: 4
    t.integer  "amount",            limit: 4
    t.integer  "my_account_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "no_monthly_report",               default: false
    t.boolean  "monthly_data",                    default: false
    t.integer  "corporation_code",  limit: 4
  end

  add_index "receipt_headers", ["account_id"], name: "index_receipt_headers_on_account_id", using: :btree
  add_index "receipt_headers", ["corporation_code"], name: "index_receipt_headers_on_corporation_code", using: :btree
  add_index "receipt_headers", ["item_id"], name: "index_receipt_headers_on_item_id", using: :btree
  add_index "receipt_headers", ["my_account_id"], name: "index_receipt_headers_on_my_account_id", using: :btree
  add_index "receipt_headers", ["user_id"], name: "index_receipt_headers_on_user_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "filename",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "bank_transfers", "payment_headers"
  add_foreign_key "bank_transfers", "receipt_headers"
end
