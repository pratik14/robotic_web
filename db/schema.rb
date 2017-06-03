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

ActiveRecord::Schema.define(version: 20170603080357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: true do |t|
    t.integer  "test_case_id"
    t.integer  "keyword_id"
    t.integer  "order_number"
    t.string   "url"
    t.string   "locator"
    t.string   "text"
    t.string   "expected"
    t.string   "value"
    t.string   "condition"
    t.text     "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "events", ["keyword_id"], name: "index_events_on_keyword_id", using: :btree
  add_index "events", ["test_case_id"], name: "index_events_on_test_case_id", using: :btree

  create_table "keywords", force: true do |t|
    t.string   "name"
    t.text     "documentation"
    t.text     "arguments",     default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_cases", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "status"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_file_file_name"
    t.string   "source_file_content_type"
    t.integer  "source_file_file_size"
    t.datetime "source_file_updated_at"
  end

  add_index "test_cases", ["user_id"], name: "index_test_cases_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "auth_token",             default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
