class CreateIndications < ActiveRecord::Migration
  def change
    create_table :indications do |t|
      t.references :entity
      t.datetime :created_at, null: false
      t.float :value, null:false
    end

    add_index :indications, [:entity_id, :created_at]
  end
end
