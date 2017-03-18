class AddDisabledToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :disabled, :boolean, null: false, default: false
  end
end
