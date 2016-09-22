class Init < ActiveRecord::Migration
  def change
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
      t.string  "name",           null: false
      t.integer "parent_id"
      t.string  "type",           null: false
      t.string  "caption",        null: false
      t.string  "address"
      t.float   "value"
      t.float   "location_x"
      t.float   "location_y"
      t.float   "power"
      t.string  "driver"
      t.integer "lft",            null: false
      t.integer "rgt",            null: false
      t.integer "depth"
      t.integer "children_count"
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
end
