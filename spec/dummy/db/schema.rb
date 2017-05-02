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

ActiveRecord::Schema.define(version: 20170318143219) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
  end

  add_index "delayed_jobs", ["entity_id", "queue"], name: "index_delayed_jobs_on_entity_id_and_queue"
  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "entities", force: :cascade do |t|
    t.string  "name",                           null: false
    t.integer "parent_id"
    t.string  "type",                           null: false
    t.string  "caption",                        null: false
    t.string  "address"
    t.float   "value"
    t.float   "location_x"
    t.float   "location_y"
    t.float   "power"
    t.string  "driver"
    t.integer "lft",                            null: false
    t.integer "rgt",                            null: false
    t.integer "depth"
    t.integer "children_count"
    t.binary  "attrs"
    t.boolean "disabled",       default: false, null: false
  end

  add_index "entities", ["name"], name: "index_entities_on_name", unique: true
  add_index "entities", ["parent_id"], name: "index_entities_on_parent_id"

  create_table "indications", force: :cascade do |t|
    t.integer  "entity_id"
    t.datetime "created_at", null: false
    t.float    "value",      null: false
  end

  add_index "indications", ["entity_id", "created_at"], name: "index_indications_on_entity_id_and_created_at"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "isadmin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["name"], name: "index_users_on_name", unique: true

end
