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

ActiveRecord::Schema.define(version: 20170303100843) do

  create_table "events", force: true do |t|
    t.integer  "test_case_id"
    t.string   "locator"
    t.string   "keyword"
    t.string   "value"
    t.string   "element"
    t.string   "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "events", ["test_case_id"], name: "index_events_on_test_case_id"

  create_table "test_cases", force: true do |t|
    t.string   "name"
    t.string   "status"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_file_file_name"
    t.string   "source_file_content_type"
    t.integer  "source_file_file_size"
    t.datetime "source_file_updated_at"
  end

end
