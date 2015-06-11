class CreateEntities < ActiveRecord::Migration
  def change
    create_table "entities", force: true do |t|
      t.string  "name",      null: false
      t.integer "parent_id"
      t.string  "type",      null: false
      t.string  "caption",   null: false
      t.string  "address"
      t.float   "value",     null: false, default: 0
      t.float "left"
      t.float "top"
      t.float "power", null: true
    end
  
    add_index "entities", ["name"], name: "index_entities_on_name", unique: true
    add_index "entities", ["parent_id"], name: "index_entities_on_parent_id"
  end
end
