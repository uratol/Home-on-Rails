class AddDisabledToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :disabled, :boolean
  end
end
