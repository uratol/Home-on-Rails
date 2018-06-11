class AddDisabledToEntities < ActiveRecord::Migration.respond_to?(:[]) ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    add_column :entities, :disabled, :boolean
  end
end
